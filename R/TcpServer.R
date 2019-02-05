#' @include Server.R
#' @include StreamConnection.R
#' @export
TcpServer <- R6::R6Class("TcpServer",
  inherit = Server,

  public = list(
    initialize = function(host="127.0.0.1", port=2000) {
      private$host <- host
      private$port <- port
    },

    url = function() {
      paste0("tcp://", private$host, ":", private$port)
    },

    listen  = function(parrallel=TRUE) {
      # Find an available port prior to forking a subprocess
      # This is not ideal as it could lead to race conditions
      # but necessary since we are unable to ge port back
      # from subprocess for `url` etc. Randomization is used to reduce chances
      # of races.
      while (TRUE) {
        socket <- tryCatch(
          socketConnection(host = private$host, port = private$port),
          warning = identity
        )
        if (methods::is(socket, "warning")) {
          if (grepl("cannot be opened$", socket$message)) break
        } else {
          private$port <- floor(runif(1, 2000, 2100))
        }
      }

      run <- function() {
        while (TRUE) {
          # This call blocks until a new connection is made
          socket <- socketConnection(
            host = private$host,
            port = private$port,
            blocking = TRUE,
            server = TRUE,
            open = "r+b", # Read/write binary
            timeout = 60 * 60
          )
          # Start a new connection for each client in a new subprocess
          # to asynchrously serve requests made on the connection
          # For debugging it can be useful to remove this `future::multiprocess`
          # wrapping so that errors are displayed
          future::multiprocess({
            connection <- StreamConnection$new(socket, socket)
            connection$listen(function(message) {
              connection$write(self$receive(message))
            })
            connection$close()
          })
        }
      }
      # For debugging it can be useful to not run this in a separate process.
      if (!parrallel) run()
      else {
        private$future <- future::multiprocess({
          run()
        })
      }
    },

    unlisten  = function() {
      if (!is.null(private$future)) {
        # On Unix systems this should work to kill the server process
        # but on Windows, another approach will be required.
        # See https://github.com/HenrikBengtsson/future/issues/93
        pid <- private$server$job$pid
        tools::pskill(pid, signal = tools::SIGTERM)
        tools::pskill(pid, signal = tools::SIGKILL)
        private$future <- NULL
      }
    }
  ),

  private = list(
    host = NULL,
    port = NULL,
    future = NULL
  )
)
