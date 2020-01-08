#' @include json-rpc.R
#' @include logger.R
#'
#' @title Server
#'
#' @description
#' A server is responsible for receiving requests to call an executor
#' method. This is an abstract base class for concreate classes of servers that will
#' each communicate with clients over alternative transports (e.g. stdio, HTTP).
#'
#' R implementation of Executa's
#' [Server](https://github.com/stencila/executa/blob/v1.6.0/src/base/Server.ts)
#' interface.
Server <- R6::R6Class(
  "Server",
  private = list(
    executor = NULL,
    log = NULL,
    error_file = NULL
  ),
  public = list(
    #' @field running A boolean indicating if this server is running
    running = FALSE,

    #' @description Initialize the server.
    #'
    #' @param executor The executor to serve
    initialize = function(executor = NULL) {
      private$executor <- executor
      private$log <- logger("rasta:server")
      self$running <- FALSE
    },

    #' @description Get the addresses of the server.
    #'
    #' A server will usually on have one address type (e.g. `stdio` or `http`)
    #' but may have more than one address for each type.
    #'
    #' @return A list of address types, with one or more addresses for each type.
    addresses = function() {
      list()
    },

    #' @description Get the URL of the server.
    #'
    #' The URL is derived from the first address.
    #' Intended mainly for easily adding the address of the
    #' server to log messages
    #'
    #' @return A URL string of the server
    url = function() {
      addresses <- self$addresses()
      if (length(addresses) > 0) {
        first <- addresses[1]
        paste0(names(first), "://", first)
      }
    },

    #' @description Receive a request.
    #'
    #' @param request The `JsonRpcRequest` (or JSON/list representation of it) to receive.
    #' @param then A function to call with the response.
    receive = function(request, then) {
      # See the equivalent implementation in Javascript:
      # https://github.com/stencila/executa/blob/v1.6.0/src/base/Server.ts#L70

      request <- tryCatch(JsonRpcRequest$create(request), error = identity)

      # Local function to make the following a little more terse
      respond <- function(...) then(JsonRpcResponse$new(...))

      if (inherits(request, "JsonRpcError"))
        respond(error = request)
      else if (inherits(request, "error"))
        respond(error = JsonRpcError$new(
          JsonRpcErrorCode$InternalError,
          error$message
        ))
      else if (is.null(private$executor))
        respond(error = JsonRpcError$new(
          JsonRpcErrorCode$ServerError,
          "No executor configured yet for this server"
        ))
      else {
        # Handle the request by dispatching to the executor
        private$executor$dispatch(
          request$method,
          request$params,
          then = function(result) {
            respond(
              id = request$id,
              result = result
            )
          },
          catch = function(error) {
            # Log error and transform into a JSON-RPC error
            message <- if (!is.null(error$message)) error$message else as.character(error)
            private$log$error(message)
            respond(
              id = request$id,
              error = JsonRpcError$new(JsonRpcErrorCode$ServerError, message)
            )
          }
        )
      }
    },

    #' @description Read a message.
    #'
    #' @note
    #' Derived classes will usally want to override this method
    #' to read a message from a specific transport.
    #'
    #' @param blocking Should the read be a blocking operation?
    #' @returns A message string. An empty string if no message was read.
    read = function(blocking = TRUE) return(""),

    #' @description Write a message.
    #'
    #' @note
    #' Derived classes will usally want to override this method
    #' to write a message to a specific transport.
    #'
    #' @param message The message to write.
    write = function(message) {
    },

    #' @description Start the server.
    #'
    #' @note
    #' When overriding this method, derived classes will usually want to
    #' call this method, i.e `super$start(executor)`
    #'
    #' @param executor The executor to dispatch to
    #' @param background Run the server in the background with this duration, in seconds,
    #' between checks for new messages.
    start = function(executor, background = -1) {
      private$log$debug(paste("Starting server:", self$url()))
      private$executor <- executor

      # Print error file path in case it is needed
      error_file_name <- tempfile(pattern = "rasta-stream-server-", fileext = ".txt")
      private$error_file <- file(error_file_name, open = "w")
      private$log$debug(paste("Error file path:", error_file_name))

      self$running <- TRUE
      if (background >= 0) {
        private$log$debug(paste("Running server in background with interval (s):", background))
        check_later <- function() {
          if (!self$running) return()
          later::later(function() {
            self$check(blocking = FALSE)
            check_later()
          }, background)
        }
        check_later()
      } else {
        while (TRUE) {
          stop <- self$check(blocking = TRUE)
          if (length(stop) && stop) {
            self$stop()
            break
          }
        }
      }
      invisible(NULL)
    },

    #' Handle requests, logging any unhandled errors or warnings
    #'
    #' @param blocking Should the read be a blocking operation?
    check = function(blocking = TRUE) {
      tryCatch({
          message <- self$read(blocking)
          if (message != "") {
            self$receive(message, then = function(response) {
              json <- response$serialize()
              self$write(json)
            })
          } else {
            # Empty message blocking read indicates stop
            if (blocking) return(TRUE)
          }
        },
        warning = function(warning) {
          log$warn(warning$message)
        },
        error = function(error) {
          # Without the following line, when the parent process is killed,
          # the R process would hang, consuming 100% CPU on the call to `log$error`,
          # and become a zombie process. This may be due to stderr being
          # closed, but attempts to detect that more intelligently did not work
          # and this seemingly useless writing of the error to a files
          # was the only way found to avoid the hanging.
          writeLines(error$message, private$error_file)

          private$log$error(error$message)
        }
      )
    },

    #' @description Stop the server
    #'
    #' Derived classes may override this method to gracefully
    #' shutdown the server e.g. close client connections.
    stop = function() {
      private$log$debug(paste("Stopping server:", self$url()))
      self$running <- FALSE

      if (inherits(private$error_file, "connection")) {
        try(close(private$error_file))
        private$error_file <- NULL
      }
    }
  )
)
