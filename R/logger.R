#' Create a logger
#'
#' The logger emits log events in a format that is
#' consistent with [`logga`](https://github.com/stencila/logga):
#' newline-delimited JSON streamed to `stderr`, with the `tag`,
#' a `message` string and an integer `level`:
#'
#' - 0: error
#' - 1: warning
#' - 2: info
#' - 3: debug
#'
#' This consistency allows for log events to be merged with
#' those from other Stencila executors, e.g. Encoda, Pyla
#' for easier cross application and cross language tracing
#' and debugging.
#'
#' @param tag The tag for all log events emitted
logger <- function(tag) {
  log_event <- function(level, message) {
    data <- list(
      tag = tag,
      time = as.POSIXlt(Sys.time(), "UTC"),
      level = level,
      message = message
    )
    json <- to_json(data)
    dest <- stderr()
    write(json, dest)
    flush(dest)
  }
  list(
    error = function(message) log_event(0, message),
    warn = function(message) log_event(1, message),
    info = function(message) log_event(2, message),
    debug = function(message) log_event(3, message)
  )
}
