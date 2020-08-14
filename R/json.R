#' Functions for JSON handling
#'
#' These functions simply provide a consistent means for calling `jsonlite`
#' functions `toJSON` and `fromJSON` from `json-rpc` and `logger`.
#'
#' @name json
#' @rdname json
NULL

#' @include util.R

library(stencilaschema)

#' Declare that a node is scalar
#'
#' So that the object is "unboxed" when serialized to JSON
#'
#' @param object The object to mark as a scalar
as_scalar <- function(object) {
  if (!is.null(object)) {
    class(object) <- c("scalar", class(object))
  }
  object
}

to_json <- function(object, pretty = FALSE) {
  # Unbox scalar properties of Stencila nodes.
  # This is necessary because otherwise numbers, strings etc get
  # stringifies as arrays of numbers, strings etc
  # It is not possible to use `auto_unbox` in `jsonlite::toJSON`
  # because that risks unboxing things that should not be e.g.
  # `DatatableColumn$values` of length 1.
  node <- transform(object, function(node) {
    cls <- head(class(node), n = 1)
    if (
      !is.null(cls) && cls == "scalar" &&
      !is.null(node) && is.atomic(node) && length(dim(node)) == 1
    ) jsonlite::unbox(node)
    else node
  })

  as.character(
    # jsonlite warnings, like this one
    # https://github.com/jeroen/jsonlite/blob/c9c22efdaeed089d503c7d85863cc050ee4d833a/R/asJSON.list.R#L41
    # cause issues (due to error handling elsewhere?) so we suppress them for now.
    suppressWarnings(
      jsonlite::toJSON(
        node,
        pretty = pretty,
        force = TRUE,
        null = "null",
        na = "null",
        Date = "ISO8601"
      )
    )
  )
}

from_json <- function(json) {
  object <- jsonlite::fromJSON(json, simplifyDataFrame = FALSE)
  to_node(object)
}

# Call Stencila node constructors with parsed JSON objects
# to (a) ensure scalar properties are
# marked as such (for when they are sent back to JSON;  see above), and
# (b) to check that they conform to the constructors
to_node <- function(node) {
  if (is.list(node)) {
    if (!is.null(node$type)) {
      func <- get0(node$type)
      if (!is.null(func)) {
        args <- map(node, to_node)
        args["type"] <- NULL
        return(do.call(func, args))
      }
    }
    return(map(node, to_node))
  }
  node
}
