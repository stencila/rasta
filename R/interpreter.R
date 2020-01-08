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
      # Note: Use `I` to avoid inadvertant unboxing to scalars
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
          compile = code_params,
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
        errors <- c(errors, list(list(
          type = "CodeError",
          kind = "InternalError",
          message = as.character(evaluation)
        )))
      } else {
        # Iterate over the evaluation object and grab any errors
        # or outputs
        for (line in evaluation) {
          if (!inherits(line, "source")) {
            if (inherits(line, "error")) errors <- c(errors, list(list(
              type = "CodeError",
              kind = "RuntimeError",
              message = as.character(line$message)
            )))
            else outputs <- c(outputs, list(line)) # TODO marshall line to JSONisable object
          }
        }
      }

      # Update the properties of the node and return it
      node$outputs <- if (length(outputs) > 0) outputs else NULL
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
      if (missing(params) || is.null(params)) params <- list()
      result <- tryCatch(do.call(func, c(params, list(then))))
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
        jsonlite::toJSON(
          self$manifest(),
          auto_unbox = TRUE,
          pretty = TRUE
        ),
        file.path(home_dir("executors", ensure = TRUE), "rasta.json")
      )
    },

    #' @description Start serving the interpreter
    start = function(background = -1) {
      for (server in private$servers) server$start(self, background = background)
    },

    #' @description Stop serving the interpreter
    stop = function() {
      for (server in private$servers) server$stop()
    }
  )
)
