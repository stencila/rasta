#' @export
StreamConnection <- R6::R6Class("StreamConnection",
  public = list(
    initialize = function(reader, writer = NULL, binary = TRUE) {
      private$reader <- reader
      private$writer <- if (is.null(writer)) reader else writer
      private$binary <- binary
    },

    read = function() {
      if (is.null(private$reader)) stop("Connection has been closed")
      if (private$binary) {
        message_length <- readBin(private$reader, integer(), 1, endian = "big")
        if (length(message_length) == 0) return(raw())
        message <- readBin(private$reader, raw(), message_length)
        message
      } else {
        readLines(private$reader, 1)
      }
    },

    write = function(message) {
      if (is.null(private$writer)) stop("Connection has been closed")
      if (private$binary) {
        if (is.character(message)) message <- charToRaw(message)
        writeBin(length(message), private$writer, endian = "big")
        writeBin(message, private$writer)
      } else {
        writeLines(message, private$writer)
      }
      flush(private$writer)
    },

    listen = function(callback) {
      while (TRUE) {
        message <- self$read()
        if (length(message) == 0) break
        else callback(message)
      }
    },

    close = function() {
      if (!is.null(private$reader)) {
        tryCatch(close(private$reader), error = identity)
        private$reader <- NULL
      }
      if (!is.null(private$writer)) {
        tryCatch(close(private$writer), error = identity)
        private$writer <- NULL
      }
    }
  ),

  private = list(
    reader = NULL,
    writer = NULL,
    binary = NULL
  )
)
