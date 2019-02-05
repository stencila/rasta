#' @include Client.R
#' @export
HttpClient <- R6::R6Class("HttpClient",
  inherit = Client,

  public = list(
    write = function(message) {
      message <- future::multiprocess({
        response <- httr::POST(self$url())
        data <- httr::content(response, as = "text")
        jsonlite::fromJSON(data)
      })
      self$read(future::value(message))
    }
  )
)
