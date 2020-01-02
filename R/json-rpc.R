#' Classes for JSON-RPC 2.0
#'
#' These classes implement the three key object
#' types of the [JSON-RPC 2.0 specification](https://www.jsonrpc.org/specification).
#'
#' For the equivalent classes in Typescript, and further documentation, see Executa.
#' e.g. [`JsonRpcRequest`](https://github.com/stencila/executa/blob/v1.6.0/src/base/JsonRpcRequest.ts)
#'
#' @rdname json-rpc.Rd

#' A JSON-RPC 2.0 request
#'
#' @rdname json-rpc.Rd
JsonRpcRequest <- R6::R6Class(
  "JsonRpcRequest",
  public = list(
    jsonrpc = NULL,
    id = NULL,
    method = NULL,
    params = NULL,

    initialize = function(method=NULL, params=NULL, id=NULL) {
      self$jsonrpc <- "2.0"
      self$id <- id
      self$method <- method
      self$params <- params
    }
  )
)

#' Create a JSON-RPC request.
#'
#' Calls `JsonRpcRequest$parse` or `JsonRpcRequest$hydrate` depending
#' on the type of the `source` argument.
#'
#' @rdname json-rpc.Rd
#' @param source A JSON string or list with the request fields
JsonRpcRequest$create <- function(source) {
  if (inherits(source, "JsonRpcRequest")) source
  else if (is.character(source)) JsonRpcRequest$parse(source)
  else if (is.list(source)) JsonRpcRequest$hydrate(source)
  else JsonRpcError$new(
    JsonRpcErrorCode$InvalidRequest,
    paste("Invalid request type:", typeof(source))
  )
}

#' Parse JSON into a JSON-RPC request
#'
#' Will return an error with the code `ParseError`
#' if the JSON can not be parsed.
#'
#' @rdname json-rpc.Rd
#' @param json The JSON to parse
JsonRpcRequest$parse <- function(json) {
  list <- tryCatch(jsonlite::fromJSON(json), error = identity)
  if (inherits(list, "error"))
    JsonRpcError$new(
      JsonRpcErrorCode$ParseError,
      paste("Parse error:", list$message)
    )
  else JsonRpcRequest$create(list)
}

#' Hydrate a list into a JSON-RPC request.
#'
#' Will return an error with code `InvalidRequest`
#' if required fields are missing or are of the
#' wrong type.
#'
#' @rdname json-rpc.Rd
#' @param json The list to use
JsonRpcRequest$hydrate <- function(list) {
  method <- list$method
  if (is.null(method))
    JsonRpcError$new(
      JsonRpcErrorCode$InvalidRequest,
      "Invalid request: missing property: \"method\""
    )
  else if (!is.character(method))
    JsonRpcError$new(
      JsonRpcErrorCode$InvalidRequest,
      paste("Invalid request: incorrect type for \"method\":", typeof(method))
    )
  else
    JsonRpcRequest$new(method, list$params, list$id)
}

#' A JSON-RPC 2.0 response
#'
#' @rdname json-rpc.Rd
JsonRpcResponse <- R6::R6Class(
  "JsonRpcResponse",
  public = list(
    jsonrpc = NULL,
    id = NULL,
    result = NULL,
    error = NULL,

    initialize = function(id=NULL, result=NULL, error=NULL) {
      self$jsonrpc <- "2.0"
      self$id <- id
      self$result <- result
      self$error <- error
    }
  )
)

#' A JSON-RPC 2.0 error
#'
#' @rdname json-rpc.Rd
JsonRpcError <- R6::R6Class(
  "JsonRpcError",
  public = list(
    code = NULL,
    message = NULL,
    data = NULL,

    initialize = function(code=NULL, message=NULL, data=NULL) {
      self$code <- code
      self$message <- message
      self$data <- data
    }
  )
)

#' Error codes defined in JSON-RPC 2.0
JsonRpcErrorCode <- list(

  #' Invalid JSON was received by the server.
  #' An error occurred on the server while parsing the JSON text.
  ParseError = -32700,

  #' The JSON sent is not a valid Request object.
  InvalidRequest = -32600,

  #' The method does not exist / is not available.
  MethodNotFound = -32601,

  #' Invalid method parameter(s).
  InvalidParams = -32602,

  #' Internal JSON-RPC error.
  InternalError = -32603,

  # Implementation defined server-errors...

  #' Generic server error.
  ServerError = -32000,

  #' Capability error
  CapabilityError = -32005
)
