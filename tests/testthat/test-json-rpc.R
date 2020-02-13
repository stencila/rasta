context("json-rpc")

test_that("can construct a request", {
  request <- JsonRpcRequest$new(
    method = "some_method",
    params = list(a = 1, b = 2),
    id = "uniqueid"
  )
  expect_true(inherits(request, "JsonRpcRequest"))
  expect_equal(request$method, "some_method")
  expect_equal(request$params, list(a = 1, b = 2))
  expect_equal(request$id, "uniqueid")
})

test_that("can create() a request from a string or a list", {
  request1 <- JsonRpcRequest$create(list(
    method = "some_method",
    params = list(a = 1, b = 2),
    id = "uniqueid"
  ))
  expect_true(inherits(request1, "JsonRpcRequest"))

  request2 <- JsonRpcRequest$create("{\"method\": \"some_method\"}")
  expect_true(inherits(request2, "JsonRpcRequest"))

  request3 <- JsonRpcRequest$create(request2)
  expect_equal(request2, request3)

  error <- JsonRpcRequest$create(42)
  expect_true(inherits(error, "JsonRpcError"))
  expect_equal(error$code, JsonRpcErrorCode$InvalidRequest)
})

test_that("can parse() a request from JSON", {
  request <- JsonRpcRequest$parse("{
    \"method\": \"some_method\",
    \"params\": {\"a\": 1, \"b\": 2},
    \"id\": \"uniqueid\"
  }")
  expect_true(inherits(request, "JsonRpcRequest"))
  expect_equal(request$method, "some_method")
  expect_equal(request$params, list(a = 1, b = 2))
  expect_equal(request$id, "uniqueid")

  request <- JsonRpcRequest$parse("%&@$%^$")
  expect_true(inherits(request, "JsonRpcError"))
  expect_equal(request$code, JsonRpcErrorCode$ParseError)
})

test_that("can dehydrate() a request to a list", {
  expect_equal(
    JsonRpcRequest$new()$dehydrate(),
    list(jsonrpc = "2.0")
  )
  expect_equal(
    JsonRpcRequest$new(method = "manifest")$dehydrate(),
    list(jsonrpc = "2.0", method = "manifest")
  )
})

test_that("can serialize() a request to JSON", {
  expect_equal(
    JsonRpcRequest$new(method = "manifest")$serialize(),
    "{\"jsonrpc\":\"2.0\",\"method\":\"manifest\"}"
  )
  expect_equal(
    JsonRpcRequest$new(method = "execute", params = list(node = 42))$serialize(),
    "{\"jsonrpc\":\"2.0\",\"method\":\"execute\",\"params\":{\"node\":42}}"
  )
})

test_that("can construct a response", {
  request <- JsonRpcResponse$new(
    id = "uniqueid",
    result = 42
  )
  expect_true(inherits(request, "JsonRpcResponse"))
  expect_equal(request$id, "uniqueid")
  expect_equal(request$result, 42)
  expect_equal(request$error, NULL)
})

test_that("can serialize() a response to JSON ", {
  expect_equal(
    JsonRpcResponse$new(id = "an-id", result = stencilaschema::CodeChunk(
      programmingLanguage = "r",
      text = "head(mtcars)",
      outputs = list(head(mtcars))
    ))$serialize(),
    # nolint start
    "{\"jsonrpc\":\"2.0\",\"id\":\"an-id\",\"result\":{\"type\":\"CodeChunk\",\"text\":\"head(mtcars)\",\"programmingLanguage\":\"r\",\"outputs\":[[{\"mpg\":21,\"cyl\":6,\"disp\":160,\"hp\":110,\"drat\":3.9,\"wt\":2.62,\"qsec\":16.46,\"vs\":0,\"am\":1,\"gear\":4,\"carb\":4,\"_row\":\"Mazda RX4\"},{\"mpg\":21,\"cyl\":6,\"disp\":160,\"hp\":110,\"drat\":3.9,\"wt\":2.875,\"qsec\":17.02,\"vs\":0,\"am\":1,\"gear\":4,\"carb\":4,\"_row\":\"Mazda RX4 Wag\"},{\"mpg\":22.8,\"cyl\":4,\"disp\":108,\"hp\":93,\"drat\":3.85,\"wt\":2.32,\"qsec\":18.61,\"vs\":1,\"am\":1,\"gear\":4,\"carb\":1,\"_row\":\"Datsun 710\"},{\"mpg\":21.4,\"cyl\":6,\"disp\":258,\"hp\":110,\"drat\":3.08,\"wt\":3.215,\"qsec\":19.44,\"vs\":1,\"am\":0,\"gear\":3,\"carb\":1,\"_row\":\"Hornet 4 Drive\"},{\"mpg\":18.7,\"cyl\":8,\"disp\":360,\"hp\":175,\"drat\":3.15,\"wt\":3.44,\"qsec\":17.02,\"vs\":0,\"am\":0,\"gear\":3,\"carb\":2,\"_row\":\"Hornet Sportabout\"},{\"mpg\":18.1,\"cyl\":6,\"disp\":225,\"hp\":105,\"drat\":2.76,\"wt\":3.46,\"qsec\":20.22,\"vs\":1,\"am\":0,\"gear\":3,\"carb\":1,\"_row\":\"Valiant\"}]]}}"
    # nolint end
  )
})
