context("stream-server")

test_that("will read and write messages over streams", {
  incoming <- tempfile()
  outgoing <- tempfile()
  server <- StreamServer$new(NULL, incoming, outgoing)

  request <- JsonRpcRequest$new(method = "manifest")
  jsonrpc <- request$serialize()
  stream_write_message(jsonrpc, incoming)
  expect_equal(server$read(), jsonrpc)

  response <- JsonRpcResponse$new(result = 42)
  jsonrpc <- response$serialize()
  server$write(jsonrpc)
  message <- stream_read_message(outgoing)
  expect_true(is.character(message))
  expect_equal(message, jsonrpc)
})
