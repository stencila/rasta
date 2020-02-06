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
# using snake_case convention

decode_image_object <- function(value, format = "png") {
  # Check that a graphics device exists for the requested format
  if (!exists(format)) stop(paste("Unsupported format", format))
  
  # Create a new graphics device for the format, with
  # a temporary path
  filename <- tempfile(fileext = paste0(".", format))
  get(format)(filename)
  print(value)
  grDevices::dev.off()

  # Return an ImageObject with the file contents base64 encoded
  data_uri <- paste0("data:image/", format, ";base64,", base64enc::base64encode(filename))
  stencilaschema::ImageObject(contentUrl = data_uri)
}
