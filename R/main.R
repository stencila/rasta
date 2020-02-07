#' @include globals.R
#' @include interpreter.R
#' @include stdio-server.R
#' @include pipe-server.R
#' @useDynLib rasta
#' @importFrom Rcpp sourceCpp
NULL

#' Register the interpreter
#'
#' @seealso [`Interpreter$register`](Interpreter.html#method-register)
#' @export
register <- function() Interpreter$new()$register() #nocov

#' Start the interpreter
#'
#' @seealso [`Interpreter$start`](Interpreter.html#method-start)
#' @export
#'
#' @param stdio Start a [`StdioServer`] for the interpreter?
#' @param pipe Start a [`PipeServer`] for the interpreter?
#' @param background Run the interpreter in the background with this duration, in seconds.
start <- function(stdio = TRUE, pipe = FALSE, background = -1) {
  # If this is an interactive environment then do not
  # start StdioServer and ensure that the server is run in the
  # background.
  if (isatty(stdin()) || Sys.getenv("RSTUDIO") == "1") {
    stdio <- FALSE
    background <- 0.1
  }

  servers <- list()
  if (stdio) servers <- c(servers, StdioServer$new())
  if (pipe || length(servers) == 0) servers <- c(servers, PipeServer$new())

  interpreter <- Interpreter$new(servers)
  globals[["interpreter"]] <- interpreter
  interpreter$start(background = background)

  invisible(interpreter)
}

#' Stop the interpreter
#'
#' @export
stop_ <- function() {
  interpreter <- globals[["interpreter"]]
  if (!is.null(interpreter)) {
    interpreter$stop()

    invisible(interpreter)
  }
}
