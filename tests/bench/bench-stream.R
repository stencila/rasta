# Create a temporary file stream that can be read and written to
# Use stream for R tests, so that it does not create a new connection fo each itertion.
filename <- tempfile()
stream <- file(filename, "w+b")

# Reading messages of different sizes
bench::press(
  size = c(1, 10, 100, 1000, 10000), {
    message <- paste(rep("a", size), collapse = "")
    rasta:::stream_write_message(message, stream, offset = 0, cpp = FALSE)
    bench::mark(
      # Seek to start of stream for each read
      r = rasta:::stream_read_message(stream, offset = 0, cpp = FALSE),
      cpp = rasta:::stream_read_message(filename, offset = 0, cpp = TRUE)
    )
  }
)

# Writing messages of different sizes
bench::press(
  size = c(1, 10, 100, 1000, 10000), {
    message <- paste(rep("a", size), collapse = "")
    bench::mark(
      r = rasta:::stream_write_message(message, stream, cpp = FALSE),
      cpp = rasta:::stream_write_message(message, filename, cpp = TRUE)
    )
  }
)

# Reading a writing messages of different sizes
bench::press(
  size = c(1, 10, 100, 1000, 10000), {
    message <- paste(rep("a", size), collapse = "")
    bench::mark(
      r = {
        rasta:::stream_write_message(message, stream, offset = 0, cpp = FALSE)
        rasta:::stream_read_message(stream, offset = 0, cpp = FALSE)
      },
      cpp = {
        rasta:::stream_write_message(message, filename, offset = 0, cpp = TRUE)
        rasta:::stream_read_message(filename, offset = 0, cpp = TRUE)
      }
    )
  }
)

# Cleanup
close(stream)
