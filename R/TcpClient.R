#' @include Client.R
#' @include StreamConnection.R
#' @export
TcpClient <- R6::R6Class("TcpClient",
  inherit = Client,

  public = list(
    initialize = function(url) {
      super$initialize(url)

      match <- stringr::str_match(url, "^tcp://([^:]+):(\\d+)$")[1, ]
      if (anyNA(match)) stop(paste("Invalid URL for TCP:", url))
      private$host <- match[2]
      private$port <- match[3]
    },

    open = function() {
      socket <- socketConnection(
        host = private$host,
        port = private$port,
        blocking = TRUE,
        open = "r+b", # Read/write binary
        timeout = 60 * 60
      )
      private$connection <- StreamConnection$new(socket, socket)
    },

    write = function(message) {
      private$connection$write(message)
      message <- private$connection$read()
      if (length(message) == 0) self$close()
      else self$read(message)
    },

    close = function() {
      if (!is.null(private$connection)) {
        private$connection$close()
      }
    }
  ),

  private = list(
    host = NULL,
    port = NULL,
    connection = NULL
  )
)
