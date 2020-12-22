# A codec for encoding / decoding between R objects
# and Stencila Schema nodes.

#' @include logger.R
#' @include util.R

log <- logger("rasta:codec")

#' Decode an R value to a Stencila `Node`
#'
#' If there is not yet an explicit handler for a R value type
#' then logs a warning and returns the value as the string output
#' from `print` (which may be customized e.g. `print.table` is used for the results of `summary()`).
#'
#' @param value The R value to decode
#' @param options Options for decoding
#' @export
decode <- function(value, options = list()) {
  # Of course, the order of these if statements is important.
  # Generally, have the more specific items at the top.
  # Rearrange with caution (and testing!)
  if (inherits(value, "recordedplot") || inherits(value, "ggplot")) {
    # Decode to an ImageObject
    decode_image_object(value, options = options)
  } else if (inherits(value, "table")) {
    # The functions `summary` and `table` return class "table" results
    # Currently, just "print" them.
    # In the future, we may convert these to Datatables.
    paste(utils::capture.output(print(value)), collapse = "\n")
  } else if (is.data.frame(value)) {
    # Decode to a Datatable
    decode_datatable(value)
  } else if (is.list(value)) {
    # Deep decode the list (i.e. decode values of the list and return a list)
    transform(value, decode)
  } else if (is.matrix(value) || is.array(value) || is.vector(value)) {
    # Return value because, for these types, `to_json()` will convert
    # to the appropriate JSON type e.g. a matrix to an array or arrays
    value
  } else {
    log$warn(paste("Default conversion for R type:", typeof(value), ", class:", class(value)))
    paste(utils::capture.output(print(value)), collapse = "\n")
  }
}

# The following functions are named after the Stencila schema node types that
# they decode R objects **to** (using snake_case convention).

decode_image_object <- function(value, options = list(), format = "png") {
  # Check that a graphics device exists for the requested format
  if (!exists(format)) {
    log$warn(paste("Unsupported format, defaulting to PNG:", format))
    format <- "png"
  }

  # Create a new graphics device for the format, with
  # a temporary path
  filename <- tempfile(fileext = paste0(".", format))
  width <- try(as.numeric(options$width))
  height <- try(as.numeric(options$height))

  func <- get(format)
  func(
    filename,
    width = ifelse(is.numeric(width) && length(width) == 1, width, 10),
    height = ifelse(is.numeric(height) && length(width) == 1, height, 10),
    units = "cm",
    res = 150
  )
  print(value)
  grDevices::dev.off()

  # Return an ImageObject with the file contents base64 encoded
  data_uri <- paste0("data:image/", format, ";base64,", base64enc::base64encode(filename))
  stencilaschema::ImageObject(contentUrl = data_uri)
}

#' Decode an R `data.frame` to a Stencila `Datatable`
#'
#' If the data frame has row names that are not the default
#' (a sequence from 1 to `nrow`), then the first column will
#' have the name "name" and have the row names as values.
#'
#' @param df The data frame to convert
decode_datatable <- function(df) {
  row_names <- attr(df, "row.names")
  if (!identical(row_names, seq_len(nrow(df)))) {
    columns <- list(decode_datatable_column("name", row_names))
  } else {
    columns <- NULL
  }

  columns <- c(columns, filter(lapply(colnames(df), function(colname) {
    decode_datatable_column(colname, df[[colname]])
  }), function(column) !is.null(column)))

  stencilaschema::Datatable(
    columns = columns
  )
}

#' Decode a R `vector` to a Stencila `DatatableColumn`
#'
#' Because a `factor`'s levels are always a
#' character vector, factors are converted into a
#' column with `validator.items` of type `EnumValidator` with
#' `values` containing the levels.
#'
#' @param name Name of the column
#' @param object The `vector` to generate a validator and values from
decode_datatable_column <- function(name, object) {
  if (is.factor(object)) {
    validator <- stencilaschema::EnumValidator(
      values = levels(object)
    )
    values <- as.character.factor(object)
  } else if (is.logical(object)) {
    validator <- stencilaschema::BooleanValidator()
    values <- object
  } else if (is.numeric(object)) {
    validator <- stencilaschema::NumberValidator()
    values <- object
  } else if (is.character(object)) {
    validator <- stencilaschema::StringValidator()
    values <- object
  } else {
    return(NULL)
  }

  stencilaschema::DatatableColumn(
    name = name,
    values = values,
    validator = stencilaschema::ArrayValidator(items = validator)
  )
}
