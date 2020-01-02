context("server")

test_that("addresses() returns an empty list", {
  server <- Server$new()
  expect_equal(server$addresses(), list())
})

test_that("url() returns NULL", {
  server <- Server$new()
  expect_null(server$url())
})

test_that("receive() returns a response", {
  server <- Server$new()

  response <- server$receive("malformed JSON")
  expect_true(inherits(response, "JsonRpcResponse"))
  error <- response$error
  expect_equal(error$code, JsonRpcErrorCode$ParseError)
  expect_match(error$message, "Parse error: lexical error: invalid char in json text")

  response <- server$receive(list(
    method = "some_method"
  ))
  expect_true(inherits(response, "JsonRpcResponse"))
  error <- response$error
  expect_equal(error$code, JsonRpcErrorCode$ServerError)
  expect_equal(error$message, "No executor configured yet for this server")
})

test_that("start() does not error", {
  server <- Server$new()
  expect_null(server$start(NULL))
})

test_that("stop() does not error", {
  server <- Server$new()
  expect_null(server$stop())
})
