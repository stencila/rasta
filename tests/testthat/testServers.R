context("servers")

servers <- list(
  "tcp" = TcpServer,
  "http" = HttpServer,
  "ws" = WebSocketServer
)
for (name in names(servers)) {
  test_that(name, {
    server <- servers[[name]]$new()
    server$start()
    expect_match(server$url(), paste0("^", name, "://"))
    server$stop()
  })
}
