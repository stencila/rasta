#' @include stream-server.R
#' @include logger.R
#'
#' @title StdioServer
#'
#' @description
#' Server that uses standard input and output streams for message transport.
#'
#' For an equivalent class implemented in Node.js see Executa's
#' [`StdioServer`](https://github.com/stencila/executa/blob/v1.6.0/src/stdio/StdioServer.ts).
StdioServer <- R6::R6Class(
  "StdioServer",
  inherit = StreamServer,
  public = list(
    #' @description Initialize the server.
    #'
    #' @param executor The executor to serve
    initialize = function(executor = NULL) {
      super$initialize(executor, incoming = "stdin", outgoing = "stdout")
      private$log <- logger("rasta:stdio:server")
    },

    #' @field address The address of the server
    address = "R --slave --vanilla -e 'rasta::start()'",

    #' @description Get a list of server addresses
    #' Override of `Server$addresses`.
    addresses = function() {
      list("stdio" = self$address)
    }
  )
)
