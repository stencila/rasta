#' @include home.R
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
#' See [Pyla](https://github.com/stencila/pyla) and [Basha](https://github.com/stencila/basha)
#' for examples of implementations of interpreters for other languages, in other languages.
Interpreter <- R6::R6Class(
  "Interpreter",
  private = list(
    servers = list(),
    log = logger("rasta:interpreter")
  ),
  public = list(
    #' @description Initialize an `Interpreter` instance
    #'
    #' @param servers List of servers for the interpreter
    initialize = function(servers = list(StdioServer$new())) {
      private$servers <- servers
    },

    #' @description Get the manifest for the interpreter.
    #'
    #' The manifest describes the capabilities and addresses of
    #' an executor so that peers know how to delegate method calls
    #' to this interpreter.
    manifest = function() {
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
      list(
        addresses = sapply(private$servers, function(server) server$addresses()),
        capabilities = list(
          manifest = TRUE,
          compile = code_params,
          execute = code_params
        )
      )
    },

    #' @description Execute a node.
    #'
    #' @param node The node to execute. Usually, a `CodeChunk`
    #' @param ... Currently other arguments e.g. `session`, `job` are ignored
    #' @returns The executed node with properties such as `outputs` and `errors`
    #' potentially updated
    execute = function(node, ...) {
      # Execute the code with timing
      before <- proc.time()[3]
      evaluation <- tryCatch({
        evaluate::evaluate(
          node$text,
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
      node
    },

    #' @description Dispatch a call to one of the interpreter's
    #' methods
    #'
    #' @param method The name of the method
    #' @param params A list of parameter values (i.e. arguments)
    #' @param then A function to call with the result on success
    #' @param catch A function to call with any error
    dispatch = function(method, params, then, catch) {
      if (missing(params) || is.null(params)) params <- list()
      result <- tryCatch(do.call(self[[method]], params))
      if (inherits(result, "error")) {
        if (missing(catch)) stop(result)
        else catch(result)
      } else {
        then(result)
      }
    },

    #' @description Register this interpreter on this machine.
    #'
    #' Creates a manifest file for the interpreter so that
    #' it can be used as a peer by other executors.
    register = function() {
      dir <- file.path(home(), "executors")
      if (!file.exists(dir)) dir.create(dir, recursive = TRUE)
      write(
        jsonlite::toJSON(
          self$manifest(),
          auto_unbox = TRUE,
          pretty = TRUE
        ),
        file.path(dir, "rasta.json")
      )
    },

    #' @description Start serving the interpreter
    start = function() {
      for (server in private$servers) server$start(self)
    },

    #' @description Stop serving the interpreter
    stop = function() {
      for (server in private$servers) server$stop()
    }
  )
)
