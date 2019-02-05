#' @include Client.R
#' @export
MmapClient <- R6::R6Class("MmapClient",
  inherit = Client,

  public = list(

    open = function() {
      # Create listen file path
      private$path <- "/tmp/mmap-listen.txt"
      # Watch the listen file for new connection requests
      lock <- filelock::lock(paste0(private$path, ".lock"))
      cat(readLines(private$path, 1))
      writeLines(character(), private$path)
      filelock::unlock(lock)
    },

    close = function() {
    }
  ),

  private = list(
    path = NULL,
    lock = NULL
  )
)
