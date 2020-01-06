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
  private = list(
    log = logger("rasta:stdio:server")
  ),
  public = list(
    #' @field address The address of the server
    address = "R --slave --vanilla -e 'rasta::start()'",

    #' @description Get a list of server addresses
    #' Override of `Server$addresses`.
    addresses = function() {
      list("stdio" = self$address)
    },

    #' @description Start the server.
    #' Override of `StreamServer$start` that initializes
    #' incoming and outgoing streams to use `stdin` and `stdout`
    #' respectively.
    #'
    #' @param executor The executor to serve
    start = function(executor) {
      super$start(executor, incoming = "stdin", outgoing = "stdout")
    }
  )
)
