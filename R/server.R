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
    log = NULL
  ),
  public = list(
    #' @description Initialize the server.
    #'
    #' @param executor The executor to serve
    initialize = function(executor = NULL) {
      private$executor <- executor
      private$log <- logger("rasta:server")
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

    #' @description Start the server.
    #'
    #' When overriding this method, derived classes should
    #' call this method, or ensure that `executor` is set themselves.
    #'
    #' @param executor The executor to dispatch to
    start = function(executor) {
      private$log$debug(paste("Starting server:", self$url()))
      private$executor <- executor
    },

    #' @description Stop the server
    #'
    #' Derived classes may override this method to gracefully
    #' shutdown the server e.g. close client connections.
    stop = function() {
      private$log$debug(paste("Stopping server:", self$url()))
    }
  )
)
