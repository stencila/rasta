context("client-servers")

protocols <- list(
  "tcp" = list(client = TcpClient, server = TcpServer)
)
for (name in names(protocols)) {
  test_that(name, {
    Server <- protocols[[name]]$server
    server <- Server$new()
    url <- server$start()

    Client <- protocols[[name]]$client
    client <- Client$new(url)

    Sys.sleep(0.1)
    client$start()

    client$send(JsonRpcRequest$new())

    client$stop()
    server$stop()
  })
}
