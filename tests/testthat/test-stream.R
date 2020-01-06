context("stream")

test_that("stream_read_varint and stream_write_varint work", {
  stream <- file(tempfile(), "w+b")
  for (value in c(0, 1, 42, 100, 123456, .Machine$integer.max)) {
    seek(stream, 0, "start")
    stream_write_varint(stream, value)
    seek(stream, 0, "start")
    expect_equal(stream_read_varint(stream), value)
  }
  close(stream)
})

test_that("stream_read_message and stream_write_message R implementations work", {
  stream <- file(tempfile(), "w+b")
  for (message in c("Hello world", "1", "[1,2,3]")) {
    stream_write_message(message, stream, 0, cpp = FALSE)
    expect_equal(stream_read_message(stream, 0, cpp = FALSE), message)
  }
  close(stream)
})

test_that("stream_read_message returns an empty string", {
  filename <- tempfile()
  stream <- file(filename, "w+b")
  expect_equal(stream_read_message(stream, cpp = FALSE), "")
  expect_equal(stream_read_message(filename, cpp = TRUE), "")
  close(stream)
})

test_that("get an error when attempting to write binary to stdout in R", {
  # This test is just to document the issue with attempting to
  # use `writeBin` on `stdout.`
  expect_error(
    stream_write_message("Hello world", stream = stdout(), cpp = FALSE),
    "can only write to a binary connection"
  )
})
