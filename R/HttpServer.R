#' @include TcpServer.R
#' @export
HttpServer <- R6::R6Class("HttpServer",
  inherit = TcpServer,

  public = list(
    initialize = function(host="127.0.0.1", port=3000) {
      super$initialize(host, port)
    },

    url = function() {
      paste0("http://", private$host, ":", private$port)
    },

    handlers = function() {
      list(
        call = function(req) {
          list(
            status = 200L,
            headers = list(
              "Content-Type" = "text/html"
            ),
            body = "Hello world!"
          )
        }
      )
    },

    listen  = function() {
      while (private$port < 3100) {
        server <- tryCatch(
          httpuv::startServer(private$host, private$port, self$handlers()),
          error = identity
        )
        if (methods::is(server, "error")) {
          private$port <- private$port + 1
        } else {
          private$server <- server
          break
        }
      }
    },

    unlisten  = function() {
      if (!is.null(private$server)) httpuv::stopServer(private$server)
    }
  ),

  private = list(
    server = NULL
  )
)
