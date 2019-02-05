Client <- R6::R6Class("Client",
  public = list(

    initialize = function(url) {
      private$.url <- url
      private$encoder <- JsonEncoder$new()
    },

    url = function() {
      private$.url
    },

    start = function() {
      self$open()
      self$log("started", url = self$url())
    },

    stop = function() {
      self$close()
      self$log("stopped")
    },

    open  = function() {
    },

    close  = function() {
    },

    send = function(request) {
      self$write(self$encode(request))
    },

    receive = function(response) {
      print(c("received response", response))
    },

    encode = function(request) {
      private$encoder$encode(request)
    },

    decode = function(message) {
      private$encoder$decode(message, JsonRpcResponse)
    },

    write  = function(message) {
      stop("Not implemented") # nocov
    },

    read  = function(message) {
      self$receive(self$decode(message))
    },

    log = function(message, ...) {
      #args <- c(as.list(environment()), list(...))
      cat(message, "\n")
    }

  ),

  private = list(
    .url = NULL,
    encoder = NULL
  )
)
