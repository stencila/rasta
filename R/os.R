# Operating specific functions

#' Get the Stencila home directory.
#'
#' This is the directory that Stencila configuration settings, such as the
#' installed executors get stored.
#'
#' @param subdir A subdirectory to create
#' @param ensure Ensure that the directory (and `subdir` if specified) are present?
home_dir <- function(subdir = NULL, ensure = FALSE) {
  dir <- switch(
    tolower(Sys.info()["sysname"]),
    darwin = file.path(Sys.getenv("HOME"), "Library", "Application Support", "Stencila"),
    linux = file.path(Sys.getenv("HOME"), ".stencila"),
    windows = file.path(Sys.getenv("APPDATA"), "Stencila")
  )
  if (!is.null(subdir)) dir <- file.path(dir, subdir)
  if (ensure && !file.exists(dir)) dir.create(dir, recursive = TRUE)
  dir
}

#' Get the Stencila temporary directory.
#'
#' This is the directory that Stencila stores temporary files, such as
#' named pipes. This is different to [`tempdir()`] (which includes a unique
#' identifier for the R session) because it needs to be discoverable by other
#' Stencila apps, e.g. Executa.
#'
#' The temporary directory is determined from the first of the following:
#' - the environment variables, `TMPDIR`, `TEMP`, and `TMP`, in that order
#' - on Windows, the directories `C:\TEMP`, `C:\TMP`, `\TEMP`, and `\TMP`, in that order
#' - on all other platforms, the directories `/tmp`, `/var/tmp`, and `/usr/tmp`, in that order
#' - the current working directory.
#'
#' @param subdir A subdirectory to create
#' @param ensure Ensure that the directory (and `subdir` if specified) are present?
tmp_dir <- function(subdir = NULL, ensure = FALSE) {
  os_tmp_dir <- function() {
    env_vars <- filter(
      Sys.getenv(c("TMPDIR", "TEMP", "TMP"), names = FALSE),
      function(var) nchar(var) > 0
    )
    if (length(env_vars) > 0) return(env_vars[1])

    dirs <- filter(
      switch(
        tolower(Sys.info()["sysname"]),
        windows = c("C:\\TEMP", "C:\\TMP", "\\TEMP", "\\TMP"),
        c("/tmp", "/var/tmp", "/usr/tmp")
      ),
      file.exists
    )
    if (length(dirs) > 0) return(dirs[1])

    getwd()
  }
  dir <- file.path(os_tmp_dir(), "stencila")
  if (!is.null(subdir)) dir <- file.path(dir, subdir)
  if (ensure && !file.exists(dir)) dir.create(dir, recursive = TRUE)
  dir
}
