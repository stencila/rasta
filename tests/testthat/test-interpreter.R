context("interpreter")

test_that("manifest() returns a list with a Manifest interface", {
  interpreter <- Interpreter$new()
  manifest <- interpreter$manifest()
  expect_true(is.list(manifest))
  expect_equal(names(manifest$addresses), "stdio")
  expect_true(manifest$capabilities$manifest)
})

test_that("dispatch() works", {
  interpreter <- Interpreter$new()
  manifest <- interpreter$dispatch("manifest")
  expect_equal(manifest, interpreter$manifest())
})

test_that("register() writes a manifest file", {
  interpreter <- Interpreter$new()
  expect_null(interpreter$register())
})

test_that("start() and stop() do not error", {
  # This test does not use the default StdioServer
  # because that blocks waiting for stdin input.
  interpreter <- Interpreter$new(servers = list(
    StreamServer$new(
      incoming = file("stdin", "rb", blocking = FALSE),
      outgoing = file(tempfile(), "wb")
    )
  ))
  expect_null(interpreter$start())
  expect_null(interpreter$stop())
})
