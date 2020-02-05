context("interpreter")

test_that("manifest() returns a list with a Manifest interface", {
  interpreter <- Interpreter$new()
  manifest <- interpreter$manifest()
  expect_true(is.list(manifest))
  expect_equal(names(manifest$addresses), "stdio")
  expect_true(manifest$capabilities$manifest)
})

test_that("execute() works with a CodeChunk", {
  interpreter <- Interpreter$new()

  chunk <- interpreter$execute(stencilaschema::CodeChunk(
    programmingLanguage = "r",
    text = "6 * 7"
  ))
  expect_equal(chunk$outputs, list(c(42)))
  expect_null(chunk$errors)
  expect_true(chunk$duration > 0)
})

test_that("execute() persists session state between calls", {
  interpreter <- Interpreter$new()

  chunk <- interpreter$execute(stencilaschema::CodeChunk(
    programmingLanguage = "r",
    text = "a <- 21\nb <- list(c = 32)\nlibrary(tools)"
  ))
  chunk <- interpreter$execute(stencilaschema::CodeChunk(
    programmingLanguage = "r",
    text = "a\nb\n'package:tools' %in% search()\nmode(assertWarning)"
  ))
  expect_equal(chunk$outputs, list(21, list(c = 32), TRUE, "function"))
  expect_null(chunk$errors)
})

test_that("execute() throws expected errors", {
  interpreter <- Interpreter$new()

  chunk <- interpreter$execute(stencilaschema::CodeChunk(
    programmingLanguage = "r",
    text = "foo"
  ))
  expect_null(chunk$outputs)
  expect_equal(chunk$errors, list(stencilaschema::CodeError(
    errorType = "RuntimeError",
    errorMessage = "object 'foo' not found"
  )))

  chunk <- interpreter$execute(stencilaschema::CodeChunk(
    programmingLanguage = "r",
    text = "bad syntax!"
  ))
  expect_null(chunk$outputs)
  expect_true(inherits(chunk$errors[[1]], "CodeError"))
})

test_that("dispatch() works", {
  interpreter <- Interpreter$new()
  interpreter$dispatch("manifest", then = function(manifest) {
    expect_equal(manifest, interpreter$manifest())
  })
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
      incoming = tempfile(),
      outgoing = tempfile()
    )
  ))
  expect_null(interpreter$start())
  expect_null(interpreter$stop())
})
