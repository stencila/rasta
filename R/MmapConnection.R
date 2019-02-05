# Protocol constants
MMAP_EMPTY_FLAG <- as.raw(0)
MMAP_CLOSE_FLAG <- as.raw(3)
MMAP_SIZE_BYTES <- 4
MMAP_SIZE_ENDIAN <- "big"
MMAP_SIZE_SIGNED <- FALSE

#' @export
MmapConnection <- R6::R6Class("MmapConnection",
  public = list(
    path = NULL,

    initialize = function(path = NULL, dir = NULL, size = 1e7L) {
      # If no path is specified then assume a new connection
      # with this end of the connection having flag 'A'.
      # Otherwise, connecting to an existing path.
      if (is.null(path)) {
        path <- tempfile()
        private$read_flag <- as.raw(1)
        private$write_flag <- as.raw(2)
      } else {
        private$read_flag <- as.raw(2)
        private$write_flag <- as.raw(1)
      }

      if (!file.exists(path)) {
        # Create file of desired size filled with zero bytes
        # Python has `os.truncate` for doing this, but here
        # `writeBin` appears to be best option.
        # Additional 5 bytes for read/write flag and message length
        writeBin(raw(size + 5), path)
      }
      # Set path and make it read only
      self$path <- path
      lockBinding("path", self)

      # Create the memory maping
      private$map <- mmap::mmap(path, mode = raw())
    },

    size = function() {
      length(private$map) - 5
    },

    read = function(wait=1e-5) {
      if (is.null(private$map)) stop("Connection has been closed")
      while (TRUE) {
        if (private$map[1] == private$read_flag) {
          # Other end has posted a message
          message_length <- readBin(private$map[2:5], what = "integer", endian = "big")
          message <- private$map[6:(6 + message_length - 1)]
          private$map[1] <- MMAP_EMPTY_FLAG
          return(message)
        } else if (private$map[1] == MMAP_CLOSE_FLAG) {
          mmap::munmap(private$map)
          break
        }
        if (wait > 0) Sys.sleep(wait)
        else break
      }
    },

    write = function(message) {
      if (is.null(private$map)) stop("Connection has been closed")
      message_length <- as.integer(length(message))
      if (message_length > self$size()) stop("Message is larger than connection size")
      private$map[2:5] <- writeBin(message_length, raw(), endian = "big")
      private$map[6:(6 + message_length - 1)] <- message
      private$map[1] <- private$write_flag
    },

    listen = function(callback) {
      while (TRUE) {
        message <- self$read()
        if (length(message) == 0) break
        else callback(message)
      }
    },

    close = function() {
      if (!is.null(private$map)) {
        # Tell other end to close the connection
        private$map[1] <- MMAP_CLOSE_FLAG
        # Unmap memory
        mmap::munmap(private$map)
        private$map <- NULL
      }
    }
  ),

  private = list(
    read_flag = NULL,
    write_flag = NULL,
    map = NULL
  )
)
