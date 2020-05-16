context("logger")

test_that("default log handler sends ND-JSON events to stderr", {
  log <- logger("rasta:test")

  # Ensure that using default handler
  current_handler  <- get_log_handler()
  set_log_handler(default_log_handler)

  # Divert stderr to a text stream
  out <- textConnection("out", "w")
  sink(out, type = "message")

  log$debug("for debugging")
  log$info("some info")
  log$warn("a warning")
  log$error("an error")

  # End diversion, read the text stream, join lines
  # into a JSON array and parse into a data frame (jsonlite
  # default for an array of objects)
  sink(type = "message")
  lines <- textConnectionValue(out)
  json <- paste("[", paste(lines, collapse = ","), "]")
  events <- jsonlite::fromJSON(json)
  close(out)

  # Restore log handler
  set_log_handler(current_handler)

  expect_equal(events$tag, rep("rasta:test", 4))
  expect_equal(class(strptime(events$time, "%Y-%m-%dT%H:%M:%S%z")), c("POSIXlt", "POSIXt"))
  expect_equal(events$level, c(3, 2, 1, 0))
  expect_equal(events$message, c("for debugging", "some info", "a warning", "an error"))
})

test_that("falls back to default_log_handler", {
  log <- logger("rasta:test")
  set_log_handler(NULL)

  out <- textConnection("out", "w")
  sink(out,  type = "message")
  log$debug("this should not fail")
  sink(type = "message")
  lines <- textConnectionValue(out)

  set_log_handler(default_log_handler)

  entry <- jsonlite::fromJSON(lines[1])
  expect_equal(entry$message, "this should not fail")
})
