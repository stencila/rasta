#' Functions for JSON handling
#'
#' These functions simply provide a consistent means for calling `jsonlite`
#' functions `toJSON` and `fromJSON` from `json-rpc` and `logger`.
#'
#' @name json
#' @rdname json
NULL

to_json <- function(object, pretty = FALSE) {
  as.character(
    jsonlite::toJSON(
      object,
      pretty = pretty,
      force = TRUE,
      auto_unbox = TRUE,
      null = "null",
      na = "null",
      Date = "ISO8601"
    )
  )
}

from_json <- function(json) {
  jsonlite::fromJSON(json, simplifyDataFrame = FALSE)
}
