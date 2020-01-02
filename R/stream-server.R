#' @include server.R
#' @include stream.R
#' @include logger.R

log <- logger("rasta:stream:server")
error_file <- tempfile(pattern = "rasta-stream-server-", fileext = ".txt")

#' Server that uses streams as message transport.
#'
#' For an equivalent class implemented in Node.js see Executa's
#' [`StreamServer`](https://github.com/stencila/executa/blob/v1.6.0/src/stream/StreamServer.ts).
StreamServer <- R6::R6Class(
  "StreamServer",
  inherit = Server,
  private = list(
    incoming = NULL,
    outgoing = NULL
  ),
  public = list(
    #' @description Initialize the server.
    #'
    #' @param executor The executor to serve
    #' @param incoming The stream to read messages from
    #' @param outgoing The stream to write messages to
    initialize = function(executor = NULL, incoming = NULL, outgoing = NULL) {
      super$initialize(executor)
      private$incoming <- incoming
      private$outgoing <- outgoing
    },

    #' @description Start the server.
    #'
    #' @details
    #' Override of `Server$start` that starts the server
    #' listening for requests on the incoming stream and
    #' sending them on the outgoing stream.
    #'
    #' @param executor The executor to serve
    #' @param incoming The stream to read messages from
    #' @param outgoing The stream to write messages to
    start = function(executor, incoming = NULL, outgoing = NULL) {
      super$start(executor)
      if (!is.null(incoming)) private$incoming <- incoming
      if (!is.null(outgoing)) private$outgoing <- outgoing

      # Print error file path in case it is needed
      log$debug(paste("Error file: ", error_file))

      while (TRUE) {
        # If either of the connection's streams are closed then
        # stop the server.
        if (!(
          isOpen(private$incoming) &&
          isOpen(private$outgoing)
        )) {
          self$stop()
          break
        }
        # Handle requests, logging any unhandled errors or warnings
        tryCatch({
            message <- stream_read_message(private$incoming)
            if (!is.null(message)) {
              response <- self$receive(message)
              stream_write_message(private$outgoing, response)
            } else {
              break
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
            writeLines(error$message, error_file)

            log$error(error$message)
          }
        )
      }
    },

    #' @description Stop the server.
    #'
    #' @details
    #' Override of `Server$stop` to close incoming and outgoing
    #' streams.
    stop = function() {
      if (!is.null(private$incoming)) {
        tryCatch(close(private$incoming), error = identity)
        private$incoming <- NULL
      }
      if (!is.null(private$outgoing)) {
        tryCatch(close(private$outgoing), error = identity)
        private$outgoing <- NULL
      }
      super$stop()
    }
  )
)
