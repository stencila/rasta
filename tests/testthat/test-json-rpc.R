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

test_that("can create a request from a string or a list", {
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

test_that("can parse a request from JSON", {
  request <- JsonRpcRequest$parse("{
    \"method\": \"some_method\",
    \"params\": {\"a\": 1, \"b\": 2},
    \"id\": \"uniqueid\"
  }")
  expect_true(inherits(request, "JsonRpcRequest"))
  expect_equal(request$method, "some_method")
  expect_equal(request$params, list(a = 1, b = 2))
  expect_equal(request$id, "uniqueid")
})

test_that("get an error with malformed JSON", {
  request <- JsonRpcRequest$parse("%&@$%^$")
  expect_true(inherits(request, "JsonRpcError"))
  expect_equal(request$code, JsonRpcErrorCode$ParseError)
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
