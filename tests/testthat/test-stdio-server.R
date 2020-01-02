context("stdio-server")

test_that("url() return a URL starting with stdio://", {
  server <- StdioServer$new()
  expect_match(server$url(), "stdio://")
})
