Server <- R6::R6Class("Server",
  public = list(

    start = function() {
      self$listen()
      self$url()
    },

    stop = function() {
      self$unlisten()
    },

    log = function(message=NULL, ...) {
      cat(message, "\n")
    },

    receive = function(message, encoding, connection = NULL) {
      #request = self$decode(message, encoding)
      #response = JsonRpcResponse$new()
      #self$encode(response)

      # Currently, just returning the message
      message
    },

    # Methods that must be overridden in derived classes

    url  = function() {
      stop("Not implemented") # nocov
    },

    listen  = function() {
      stop("Not implemented") # nocov
    },

    unlisten  = function() {
      stop("Not implemented") # nocov
    }
  )
)
