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

test_that("execute() works with a CodeChunk with a label, caption and id", {
  interpreter <- Interpreter$new()

  chunk <- interpreter$execute(stencilaschema::CodeChunk(
    programmingLanguage = "r",
    text = "plot(1)\nplot(2)\n",
    label = "Figure 1",
    id = "fig1",
    caption = list(
      stencilaschema::Heading(
        content = "Figure title",
        depth = 2
      ),
      stencilaschema::Paragraph(
        content = "Figure details"
      )
    )
  ))
  expect_equal(chunk$label, as_scalar("Figure 1"))
  expect_equal(chunk$id, as_scalar("fig1"))
  expect_true(is.list(chunk$caption))
  expect_equal(length(chunk$caption), 2)
  expect_null(chunk$errors)
  expect_true(chunk$duration > 0)
})

test_that("execute() works with a CodeExpression", {
  interpreter <- Interpreter$new()

  chunk <- interpreter$execute(stencilaschema::CodeExpression(
    programmingLanguage = "r",
    text = "6 * 7"
  ))
  expect_equal(chunk$output, as_scalar(42))
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

test_that("execute() sets the width and height of image outputs", {
  interpreter <- Interpreter$new()

  chunk1 <- interpreter$execute(stencilaschema::CodeChunk(
    programmingLanguage = "r",
    text = "plot(1)",
    meta = list(
      fig.width = "7",
      fig.height = 10
    )
  ))

  chunk2 <- interpreter$execute(stencilaschema::CodeChunk(
    programmingLanguage = "r",
    text = "#' @width  7\n#' @height 10\nplot(1)",
  ))

  expect_equal(chunk1$outputs, chunk2$outputs)

  chunk3 <- interpreter$execute(stencilaschema::CodeChunk(
    programmingLanguage = "r",
    text = "plot(1)",
  ))

  expect_false(isTRUE(all.equal(chunk2$outputs, chunk3$outputs)))
})


test_that("execute() produces one output for each base graphics plot", {
  interpreter <- Interpreter$new()

  # One plot created by two statements
  chunk1 <- interpreter$execute(stencilaschema::CodeChunk(
    programmingLanguage = "r",
    text = "plot(1)\nabline(0, 1)"
  ))
  expect_equal(length(chunk1$outputs), 1)

  # One plot created by three statements
  chunk2 <- interpreter$execute(stencilaschema::CodeChunk(
    programmingLanguage = "r",
    text = "plot(1)\nabline(0, 1);axis(1)"
  ))
  expect_equal(length(chunk2$outputs), 1)

  # One plot created by three statements and by two calls to plot
  # within the same chunk not separated by a different output
  chunk3 <- interpreter$execute(stencilaschema::CodeChunk(
    programmingLanguage = "r",
    text = "plot(1); abline(0, 1)\n#A comment\nplot(2)"
  ))
  expect_equal(length(chunk3$outputs), 1)

  # Two plots in the same chunk, separated by another output type
  chunk4 <- interpreter$execute(stencilaschema::CodeChunk(
    programmingLanguage = "r",
    text = "plot(1); abline(0, 1)\n'An output'\nplot(2)"
  ))
  expect_equal(length(chunk4$outputs), 3)
  expect_equal(chunk4$outputs[[1]]$type, as_scalar("ImageObject"))
  expect_equal(mode(chunk4$outputs[[2]]), "character")
  expect_equal(chunk4$outputs[[3]]$type, as_scalar("ImageObject"))
})


test_that("execute() sends warning messages to the log", {
  interpreter <- Interpreter$new()

  chunk <- interpreter$execute(stencilaschema::CodeChunk(
    programmingLanguage = "r",
    text = "warning('a warning message')"
  ))

  expect_null(chunk$outputs)

  last <- last_log()
  expect_equal(last$level, 1)
  expect_equal(last$message, "a warning message")
})

test_that("execute() sends other messages to the log", {
  interpreter <- Interpreter$new()

  chunk <- interpreter$execute(stencilaschema::CodeChunk(
    programmingLanguage = "r",
    text = "packageStartupMessage('a package startup message')"
  ))

  expect_null(chunk$outputs)

  last <- last_log()
  expect_equal(last$level, 2) # INFO level
  expect_equal(last$message, "a package startup message")
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
