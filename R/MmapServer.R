#' @include Server.R
#' @include MmapConnection.R
#' @export
MmapServer <- R6::R6Class("MmapServer",
  inherit = Server,

  public = list(
    path = NULL,
    lock = NULL,

    url = function() {
      if (!is.null(private$path)) paste0("mmap://", private$path)
      else NULL
    },

    listen = function() {
      # Create MmapConnection to listen on
      private$server <- MmapConnection$new(path = self$path)
      lockBinding("path", self)
      # Create lock file that connecing clients will need
      # to obtain to prevent races
      self$lock <- paste0(self$path, ".lock")
      lockBinding("lock", self)
      file.create(self$lock)
      # Watch the listen file for new connection requests
      private$connections <- list()
      while (TRUE) {
        # Read from the listening connection. This blocks until
        # a connection is made. In the future this read could
        # include the requested connection size.
        private$server$read()
        # Create a new connection and write it's path for the
        # client to be able to connect to it
        private$server$write(path)
        # Start listening to the connection in a new process
        connection <- future::multiprocess({
          connection <- MmapConnection$new(path)
          while (TRUE) {
            message <- connection$read()
            if (length(message) == 0) break
            else connection$write(self$receive(message))
          }
          connection$close()
          connection
        })
        private$connections <- c(private$connections, Connection)
      }
    },

    unlisten = function() {
      for (connection in private$connections) {
        connection$close()
      }
    }
  ),

  private = list(
    server = NULL,
    connections = NULL
  )
)
