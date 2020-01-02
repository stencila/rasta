#' @include interpreter.R
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
start <- function() Interpreter$new()$start() #nocov
