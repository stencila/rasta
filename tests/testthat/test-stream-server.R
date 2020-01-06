context("stream-server")

test_that("will recieve and send messages over streams", {
  interpreter <- Interpreter$new()
  incoming <- file(tempfile(), open = "w+b")
  outgoing <- file(tempfile(), open = "w+b")

  request <- JsonRpcRequest$new(method = "manifest")
  jsonrpc <- request$serialize()
  stream_write_message(jsonrpc, incoming)
  seek(incoming, 0, "start")

  server <- StreamServer$new()
  server$start(interpreter, incoming, outgoing)

  seek(outgoing, 0, "start")
  jsonrpc <- stream_read_message(outgoing)
  expect_true(is.character(jsonrpc))
  response <- JsonRpcResponse$parse(jsonrpc)
  expect_equal(response$result$addresses, interpreter$manifest()$addresses)

  server$stop()
})
