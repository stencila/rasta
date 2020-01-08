#' @include server.R
#' @include stream.R
#' @include logger.R
#'
#' @title StreamServer
#'
#' @description
#' Server that uses streams as message transport.
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
      private$log <- logger("rasta:stream:server")
      private$incoming <- incoming
      private$outgoing <- outgoing
    },

    #' @description Read a message.
    #'
    #' @note Override of [`Server`] `read` to read from
    #' a stream.
    #'
    #' @param blocking Should the read be a blocking operation?
    read = function(blocking = TRUE) {
      stream_read_message(private$incoming, blocking = blocking)
    },

    #' @description Write a message.
    #'
    #' @note Override of [`Server`] `write` to write to
    #' a stream.
    #'
    #' @param message The message to write.
    write = function(message) {
      stream_write_message(message, private$outgoing)
    },

    #' @description Stop the server.
    #' Override of `Server$stop` to close incoming and outgoing
    #' streams.
    stop = function() {
      if (inherits(private$incoming, "connection")) {
        try(close(private$incoming))
        private$incoming <- NULL
      }
      if (inherits(private$outgoing, "connection")) {
        try(close(private$outgoing))
        private$outgoing <- NULL
      }
      super$stop()
    }
  )
)
