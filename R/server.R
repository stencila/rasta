#' @include logger.R

log <- logger("rasta:server")

#' Server
#'
#' A server is responsible for receiving requests to call an executor
#' method. This is an abstract base class for concreate classes of servers that will
#' each communicate with clients over alternative transports (e.g. stdio, HTTP).
#'
#' R implementation of the
#' [`Executa.Server`](https://github.com/stencila/executa/blob/v1.4.0/src/base/Server.ts)
#' interface.
Server <- R6::R6Class(
  "Server",
  public = list(

    #' @description
    #' Get the addresses of this server.
    #'
    #' @details
    #' A server will usually on have one address type (e.g. `stdio` or `http`)
    #' but may have more than one address for each type.
    #'
    #' @return A list of address types, with one or more addresses for each type.
    addresses = function() {
      list()
    },

    #' @description
    #' Get the URL of the server.
    #'
    #' @details
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

    #' @description
    #' Receive a request.
    #'
    #' @param request The `JsonRpcRequest` to receive.
    #' @return A `JsonRpcResponse`.
    receive = function(request) {
      # See the equivalent implementation in Javascript:
      # https://github.com/stencila/executa/blob/v1.6.0/src/base/Server.ts#L70

      # Handle the request by dispatching to the executor
      id <- NULL
      handle <- function() {
        request <- JsonRpcRequest$create(request)
        id <- request$id
        
        if (inherits(request, "JsonRpcError")) return(request)
        if (is.null(private$executor)) stop("No executor configured yet for this server")
        
        private$executor$dispatch(request$method, request$params)
      }
      result <- tryCatch(handle(), error = identity)

      # Transform any errors into a JSON-RPC error
      error <- NULL
      if (inherits(result, "JsonRpcError")) error <- result
      else if (inherits(result, "error")) {
        message <- if (!is.null(result$message)) result$message else as.character(result)
        # Log other error types
        log$error(message)
        error <- JsonRpcError$new(JsonRpcErrorCode$ServerError, message)
      }

      JsonRpcResponse$new(id, result, error)
    },

    #' @description
    #' Start the server.
    #'
    #' @details
    #' When overriding this method, derived classes should
    #' call this method, or ensure that `executor` is set themselves.
    #'
    #' @param executor The executor to dispatch to
    start = function(executor) {
      log$debug(paste("Starting server:", self$url()))
      private$executor <- executor
    },

    #' @description
    #' Stop the server
    #'
    #' @details
    #' Derived classes may override this method to gracefully
    #' shutdown the server e.g. close client connections.
    stop = function() {
      log$debug(paste("Stopping server:", self$url()))
    }
  ),

  private = list(
    #' @field The executor that this server dispatches to
    executor = NULL
  )
)
