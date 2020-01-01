context("logger")

test_that("can create a logger and send ND-JSON events to stderr", {
  log <- logger("rasta:test")

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

  expect_equal(events$tag, rep("rasta:test", 4))
  expect_equal(class(strptime(events$time, "%Y-%m-%dT%H:%M:%S%z")), c("POSIXlt", "POSIXt"))
  expect_equal(events$level, c(3, 2, 1, 0))
  expect_equal(events$message, c("for debugging", "some info", "a warning", "an error"))

})
