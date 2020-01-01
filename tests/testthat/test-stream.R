context("stream")

test_that("stream_read_varint and stream_write_varint work", {
  stream <- file("testbin", "w+b")
  for (value in c(0, 1, 42, 100, 123456, .Machine$integer.max)) {
    seek(stream)
    stream_write_varint(stream, value)
    seek(stream)
    expect_equal(stream_read_varint(stream), value)
  }
})

test_that("stream_read_message and stream_write_message work", {
  stream <- file("testbin", "w+b")
  for (message in c("Hello world", "1", "[1,2,3]")) {
    seek(stream)
    stream_write_message(stream, message)
    seek(stream)
    expect_equal(stream_read_message(stream), message)
  }
})

test_that("can read messages from blocking streams", {
  stream <- file("testbin", "w+b", blocking = TRUE)
  stream_write_message(stream, "Hello world")
  seek(stream)
  expect_equal(stream_read_message(stream), "Hello world")
})

test_that("get an error when attempting to write to stdout", {
  # This test is just to document the issue with attempting to
  # use `writeBin` on `stdout.`
  expect_error(stream_write_message(stdout(), "Hello world"), "can only write to a binary connection")
})
