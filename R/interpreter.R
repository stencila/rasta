#' @include os.R
#' @include stdio-server.R
#' @include logger.R
#'
#' @title Interpreter
#'
#' @description
#' This class is an interpreter for node in executable documents that contain R code.
#' It implements the `compile`, `execute`, and other core methods of Executa's
#' [Executor](https://github.com/stencila/executa/blob/v1.6.0/src/base/Executor.ts)
#' interface.
#'
#' @details
#' Currently only handles a single session.
#'
#' See [Pyla](https://github.com/stencila/pyla) and [Basha](https://github.com/stencila/basha)
#' for examples of implementations of interpreters for other languages, in other languages.
Interpreter <- R6::R6Class(
  "Interpreter",
  private = list(
    # List of servers
    servers = NULL,
    # Logger instance for this class
    log = logger("rasta:interpreter")
  ),
  public = list(
    #' @field envir Environment for the session
    envir = NULL,

    #' @description Initialize an `Interpreter` instance
    #'
    #' @param servers List of servers for the interpreter
    initialize = function(servers = list(StdioServer$new())) {
      private$servers <- servers
      self$envir <- globalenv() # TODO: allow global or own env with new.env()
    },

    #' @description Get the manifest for the interpreter.
    #'
    #' The manifest describes the capabilities and addresses of
    #' an executor so that peers know how to delegate method calls
    #' to this interpreter.
    #'
    #' @param then A function to call with the result
    manifest = function(then) {
      # Note: Use `I` to avoid inadvertent unboxing to scalars
      # when converting to JSON
      code_params <- list(
        required = I("node"),
        properties = list(
          node = list(
            required = c("type", "programmingLanguage"),
            properties = list(
              type = list(
                enum = c("CodeChunk", "CodeExpression")
              ),
              programmingLanguage = list(
                enum = c("r", "R")
              )
            )
          )
        )
      )

      manifest <- list(
        addresses = sapply(private$servers, function(server) server$addresses()),
        capabilities = list(
          manifest = TRUE,
          execute = code_params
        )
      )
      if (!missing(then)) then(manifest)
      else return(manifest)
    },

    #' @description Execute a node.
    #'
    #' @param node The node to execute. Usually, a `CodeChunk`.
    #' @param job The job id.
    #' @param then A function to call with the result
    #' @param ... Currently other arguments e.g. `session` are ignored.
    #' @returns The executed node with properties such as `outputs` and `errors`
    #' potentially updated.
    execute = function(node, job, then, ...) {
      # Execute the code with timing
      before <- proc.time()[3]
      evaluation <- tryCatch({
        evaluate::evaluate(
          node$text,
          # Environment to evaluate in
          envir = self$envir,
          # Custom output handler for the `run` and `call` methods
          # Returns the value itself instead of the default which is to `print()` it
          output_handler = evaluate::new_output_handler(
            # No `visible` argument so that only visible values
            # are handled
            value = function(value) value
          )
        )
      }, error = identity)
      duration <- proc.time()[3] - before

      # Collect errors and outputs
      outputs <- list()
      errors <- list()
      if (inherits(evaluation, "error")) {
        # An error was caught by the tryCatch
        errors <- c(errors, list(stencilaschema::CodeError(
          errorType = "InternalError",
          errorMessage = as.character(evaluation)
        )))
      } else {
        # Iterate over the evaluation object and grab any errors
        # or outputs
        for (line in evaluation) {
          if (!inherits(line, "source")) {
            if (inherits(line, "error")) {
              errors <- c(errors, list(stencilaschema::CodeError(
                errorType = "RuntimeError",
                errorMessage = as.character(line$message)
              )))
            }
            else if (inherits(line, "warning")) {
              # Currently we do not have a place to put warnings
              # or other messages on the code chunk. Therefore,
              # send them to the log to avoid them polluting outputs.
              private$log$warn(line$message)
            }
            else if (inherits(line, "message")) {
              # As above, but treat other messages as info
              private$log$info(line$message)
            }
            else outputs <- c(outputs, list(line))
          }
        }
      }

      # Update the properties of the node and return it
      if (length(outputs) > 0) {
        if (node$type == "CodeChunk") {
          # CodeChunks can have multiple outputs
          node$outputs <- map(outputs, decode)
        } else if (node$type == "CodeExpression") {
          # CodeExpressions must have a single output, use the last one
          node$output <- decode(outputs[[length(outputs)]])
        }
      }
      node$errors <- if (length(errors) > 0) errors else NULL
      node$duration <- duration

      if (!missing(then)) then(node)
      else return(node)
    },

    #' @description Dispatch a call to one of the interpreter's
    #' methods
    #'
    #' @param method The name of the method
    #' @param params A list of parameter values (i.e. arguments)
    #' @param then A function to call with the result
    #' @param catch A function to call with any error
    dispatch = function(method, params, then, catch) {
      func <- self[[method]]
      if (is.null(func)) stop(paste("Unknown interpreter method:", method))
      if (missing(params) || is.null(params)) params <- list()
      # NOTE: With the current API, the syntax `then = then` below is important!
      # It ensures that the params are bound the correct way when making the function call
      result <- tryCatch(do.call(func, c(params, list(then = then))))
      if (inherits(result, "error")) {
        if (!missing(catch)) catch(result)
        else stop(result)
      }
    },

    #' @description Register this interpreter on this machine.
    #'
    #' Creates a manifest file for the interpreter so that
    #' it can be used as a peer by other executors.
    register = function() {
      write(
        to_json(self$manifest(), pretty = TRUE),
        file.path(home_dir("executors", ensure = TRUE), "rasta.json")
      )
    },

    #' @description Start serving the interpreter
    #'
    #' @param background Run the server in the background with this duration, in seconds,
    start = function(background = -1) {
      for (server in private$servers) server$start(self, background = background)
    },

    #' @description Stop serving the interpreter
    stop = function() {
      for (server in private$servers) server$stop()
    }
  )
)
