context("stream-server")

test_that("will recieve and send messages over streams", {
  interpreter <- Interpreter$new()
  incoming <- tempfile()
  outgoing <- tempfile()

  request <- JsonRpcRequest$new(method = "manifest")
  jsonrpc <- request$serialize()
  stream_write_message(jsonrpc, incoming)

  server <- StreamServer$new()
  server$start(interpreter, incoming, outgoing)

  jsonrpc <- stream_read_message(outgoing)
  expect_true(is.character(jsonrpc))
  response <- JsonRpcResponse$parse(jsonrpc)
  expect_equal(response$result$addresses, interpreter$manifest()$addresses)

  server$stop()
})
