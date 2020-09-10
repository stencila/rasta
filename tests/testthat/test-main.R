context("main")

test_that("start() and stop() do not error", {
  expect_error(start(background = 0.1), NA)
  expect_error(stop_(), NA)
})
