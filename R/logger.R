#' @include globals.R

#' #' Create a logger
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
    handler <- globals$log_handler
    if (!is.function(handler)) handler <- default_log_handler
    handler(data)
  }
  list(
    error = function(message) log_event(0, message),
    warn = function(message) log_event(1, message),
    info = function(message) log_event(2, message),
    debug = function(message) log_event(3, message)
  )
}

#' Get the log handler
get_log_handler <- function() {
  globals$log_handler
}

#' Set the log handler
#'
#' @param handler The log event handler
set_log_handler <- function(handler) {
  globals$log_handler <- handler
}

#' Default log handler
#'
#' Writes log data as JSON to stderr.
#' Replace this
#'
#' @param data The log event data to handle
default_log_handler <- function(data) {
  json <- jsonlite::toJSON(data, auto_unbox = TRUE, force = TRUE)
  dest <- stderr()
  write(json, dest)
  flush(dest)
}

set_log_handler(default_log_handler)
