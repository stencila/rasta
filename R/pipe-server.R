#' @include stream-server.R
#' @include logger.R
#'
#' @title PipeServer
#'
#' @description
#' Server that uses named pipes for message transport.
#'
#' On Linux and MacOS, uses named pipes, instead of files
#' to avoid touching the filesystem. Using named pipes on
#' windows should also be possible, but is not yet implemented.
PipeServer <- R6::R6Class(
  "PipeServer",
  inherit = StreamServer,
  public = list(
    #' @field address The address of this server. The base path for names pipes.
    address = "",

    #' @description Initialize the server.
    #'
    #' @param executor The executor to serve
    #' @param incoming The named pipe to read messages from
    #' @param outgoing The named pipe to write messages to
    initialize = function(executor = NULL, incoming = NULL, outgoing = NULL) {
      self$address <- file.path(tmp_dir(ensure = TRUE), paste0("rasta-", Sys.getpid(), "-pipe"))
      if (is.null(incoming)) incoming <- paste0(self$address, ".in")
      if (is.null(outgoing)) outgoing <- paste0(self$address, ".out")
      super$initialize(executor, incoming, outgoing)
      private$log <- logger("rasta:pipe:server")
    },

    #' @description Get a list of server addresses
    #' Override of `Server$addresses`.
    addresses = function() {
      list("pipe" = self$address)
    },

    #' @description Start the server.
    #' Override of `StreamServer$start` that creates named
    #' pipes if they do not yet exist.
    #'
    #' @param executor The executor to serve
    #' @param background Run the server in the background with this duration (s).
    start = function(executor, background = -1) {
      if (!file.exists(private$incoming)) pipe_make(private$incoming)
      if (!file.exists(private$outgoing)) pipe_make(private$outgoing)
      super$start(executor, background)
    },

    #' @description Stop the server.
    #' Override of `StreamServer$stop` that cleans up
    #' named pipes.
    #'
    #' @param executor The executor to serve
    stop = function() {
      super$stop()
      if (file.exists(private$incoming)) file.remove(private$incoming)
      if (file.exists(private$outgoing)) file.remove(private$outgoing)
    }
  )
)
