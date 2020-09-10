context("os")

os <- tolower(Sys.info()["sysname"])

test_that("home_dir works", {
  dir <- home_dir()
  expect_match(dir, switch(
    os,
    darwin = file.path(Sys.getenv("HOME"), "Library", "Application Support", "Stencila"),
    linux = file.path(Sys.getenv("HOME"), ".stencila"),
    windows = file.path(Sys.getenv("APPDATA"), "Stencila")
  ))

  subdir <- home_dir(subdir = "foo")
  expect_equal(subdir, file.path(dir, "foo"))
  expect_equal(file.exists(subdir), FALSE)

  subdir <- home_dir(subdir = "foo", ensure = TRUE)
  expect_equal(file.exists(subdir), TRUE)
  file.remove(subdir)
})

test_that("tmp_dir works", {
  dir <- tmp_dir()
  expect_match(dir, "stencila")

  subdir <- tmp_dir(subdir = "foo")
  expect_equal(subdir, file.path(dir, "foo"))

  subdir <- tmp_dir(subdir = "foo", ensure = TRUE)
  expect_equal(file.exists(subdir), TRUE)
  file.remove(subdir)
})
