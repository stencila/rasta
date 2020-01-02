context("stream-server")

test_that("will recieve and send messages over streams", {
  interpreter <- Interpreter$new()
  incoming <- file(tempfile(), open = "w+b")
  outgoing <- file(tempfile(), open = "w+b")

  request <- JsonRpcRequest$new(method = "manifest")
  jsonrpc <- request$serialize()
  stream_write_message(incoming, jsonrpc)
  seek(incoming)

  server <- StreamServer$new()
  server$start(interpreter, incoming, outgoing)

  seek(outgoing)
  jsonrpc <- stream_read_message(outgoing)
  response <- JsonRpcResponse$parse(jsonrpc)
  expect_equal(response$result, interpreter$manifest())

  close(incoming)
  close(outgoing)
})
