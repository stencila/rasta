#' @include HttpServer.R
#' @export
WebSocketServer <- R6::R6Class("WebSocketServer",
  inherit = HttpServer,

  public = list(
    initialize = function(host="127.0.0.1", port=4000) {
      super$initialize(host, port)
    },

    url = function() {
      paste0("ws://", private$host, ":", private$port)
    },

    handlers  = function() {
      c(super$handlers(), list(
        onWSOpen = function(ws) {
          self$log("Connection opened")

          ws$onMessage(function(binary, message) {
            ws$send(message)
          })

          ws$onClose(function() {
            self$log("Connection closed")
          })
        }
      ))
    }
  )
)
