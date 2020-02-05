#' @include logger.R
#' @include util.R

log <- logger("rasta:decode")

#' Decode an R value to a Stencila node
#'
#' If there is not yet an explicit handler for a R value type
#' then logs an error and returns `NULL`.
#' 
#' @param value The R value to decode
decode <- function(value) {
  # Of course, the order of these if statements is important.
  # Rearrange with caution (and testing!)
  if (inherits(value, "recordedplot") || inherits(value, "ggplot")) {
    decode_image_object(value)
  } else if (is.list(value)) {
    transform(value, decode)
  } else if (is.vector(value)) {
    value
  } else {
    log$warn(paste("Unhandled R value type:", typeof(value), ", class:", class(value)))
    NULL
  }
}

# The following functions are named after the Stencila schema node types that they encode **to**

decode_image_object <- function(value, format = "png") {
  # Render the plot onto the file device
  path <- tempfile(fileext = paste0(".", format))
  get(format)(path)
  if (inherits(value, "recordedplot")) graphics::replayPlot(value)
  else print(value)
  graphics::dev.off()

  # Return an ImageObject with the file contents base64 encoded
  stencilaschema::ImageObject(
    contentUrl = paste0("data:image/", format, ";base64,", base64enc::base64encode(path))
  )
}
