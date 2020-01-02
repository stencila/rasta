#' Get the Stencila home directory.
#'
#' This is the directory that Stencila configuration settings, such as the
#' installed executors get stored.
home <- function() {
  os <- tolower(Sys.info()["sysname"])
  dir <- switch(os,
    darwin = file.path(Sys.getenv("HOME"), "Library", "Application Support", "Stencila"),
    linux = file.path(Sys.getenv("HOME"), ".stencila"),
    windows = file.path(Sys.getenv("APPDATA"), "Stencila")
  )
  dir
}
