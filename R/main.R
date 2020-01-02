#' @include interpreter.R

#' Register the interpreter
#'
#' @name register
#' @export
register <- function() Interpreter$new()$register() #nocov

#' Start the interpreter
#'
#' @export
start <- function() Interpreter$new()$start() #nocov
