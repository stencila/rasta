#' @include stream-server.R
#' @include logger.R

log <- logger("rasta:stdio:server")

#' Server that uses streams as message transport.
#'
#' For an equivalent class implemented in Node.js see Executa's
#' [`StdioServer`](https://github.com/stencila/executa/blob/v1.6.0/src/stdio/StdioServer.ts).
StdioServer <- R6::R6Class(
  "StdioServer",
  inherit = StreamServer,
  public = list(
    #' @field address The address of the server
    address = "R --slave --vanilla -e 'rasta::start()'",

    #' @description Get a list of server addresses
    #'
    #' @details Override of `Server$addresses`.
    addresses = function() {
      list("stdio" = self$address)
    },

    #' @description Start the server.
    #'
    #' @details Override of `StreamServer$start` that initializes
    #' incoming and outgoing streams to use `stdin` and `stdout`
    #' respectively.
    #'
    #' @param executor The executor to serve
    start = function(executor) {
      super$start(
          executor,
          # Access the C-level stdin stream using the file function
          # to make it inary and blocking.
          incoming = file("stdin", open = "rb", blocking = TRUE),
          # Unfortunately, we can't do the same with stdout, and it is
          # always a text connection, so resort to piping to another
          # program.
          # See https://stackoverflow.com/questions/7422575/how-to-write-raw-type-bytes-to-stdout
          # In the future, to provide for operating systems without `cat`, a small C function could
          # be written to write bytes to stdout.
          outgoing = pipe("cat", "wb")
      )
    }
  )
)
