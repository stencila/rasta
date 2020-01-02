#' @include home.R
#' @include stdio-server.R
#' @include logger.R

log <- logger("rasta:interpreter")

#' Interpreter
#'
#' An interpreter for nodes in executable documents that contain R code.
#'
#' Implements the `compile`, `execute`, and other core methods of the
#' [`Executa.Executor`](https://github.com/stencila/executa/blob/v1.6.0/src/base/Executor.ts)
#' interface. See Pyla and Basha for examples of implementations of interpreters for
#' other languages.
Interpreter <- R6::R6Class(
  "Interpreter",
  private = list(
    servers = list()
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
    #' @details
    #' The manifest describes the capabilities and addresses of
    #' an executor so that peers know how to delegate method calls
    #' to this interpreter.
    manifest = function() {
      code_params <- list(
        required = "node",
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

    #' @description Register this interpreter on this machine.
    #'
    #' @details
    #' Creates a manifest file for the interpreter so that
    #' it can be used as a peer by other executors.
    register = function() {
      dir <- file.path(home(), "executors")
      if (!file.exists(dir)) dir.create(dir, recursive = TRUE)
      write(
        jsonlite::toJSON(
          self$manifest(),
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
