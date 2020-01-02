#' Classes for JSON-RPC 2.0
#'
#' These classes implement the three key object
#' types of the [JSON-RPC 2.0 specification](https://www.jsonrpc.org/specification).
#' For the equivalent classes in Typescript, and further documentation, see Executa.
#' e.g. [`JsonRpcRequest`](https://github.com/stencila/executa/blob/v1.6.0/src/base/JsonRpcRequest.ts)
#'
#' - [`JsonRpcRequest`]
#' - [`JsonRpcResponse`]
#' - [`JsonRpcError`]
#' 
#' @name json-rpc
#' @rdname json-rpc
NULL

#' @title JSON-RPC request
#' @description A class representing a JSON-RPC 2.0 request object.
JsonRpcRequest <- R6::R6Class(
  "JsonRpcRequest",
  public = list(
    #' @field jsonrpc JSON-RPC standard version identifier
    jsonrpc = "2.0",

    #' @field id Unique id of the request
    id = NULL,

    #' @field method Name of the method
    method = NULL,

    #' @field params List of parameters
    params = NULL,

    #' @description Initialize a JSON-RPC request
    #'
    #' @param method Name of the method
    #' @param params List of parameters
    #' @param id Unique id of the request
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
#' @name JsonRpcRequest$create
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
#' @name JsonRpcRequest$parse
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
#' @name JsonRpcRequest$hydrate
#' @param list The list to use
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

#' @title JSON-RPC response
#' @description A class representing a JSON-RPC 2.0 response object.
JsonRpcResponse <- R6::R6Class(
  "JsonRpcResponse",
  public = list(
    #' @field jsonrpc JSON-RPC standard version identifier
    jsonrpc = "2.0",

    #' @field id Id of the request that this response is for
    id = NULL,

    #' @field result Result of the call
    result = NULL,

    #' @field error Error associated with the call
    error = NULL,

    #' @description Initialize a JSON-RPC response
    #'
    #' @param id Id of the request that this response is for
    #' @param result Result of the call
    #' @param error Error associated with the call
    initialize = function(id=NULL, result=NULL, error=NULL) {
      self$jsonrpc <- "2.0"
      self$id <- id
      self$result <- result
      self$error <- error
    }
  )
)

#' @title JSON-RPC error
#' @description A class representing a JSON-RPC 2.0 error object.
JsonRpcError <- R6::R6Class(
  "JsonRpcError",
  public = list(
    #' @field code Numeric JSON-RPC error code
    code = NULL,

    #' @field message Message for the error
    message = NULL,

    #' @field data Any additional data associated with the error
    data = NULL,

    #' @description Initialize a JSON-RPC error
    #'
    #' @param code Numeric JSON-RPC error code
    #' @param message Message for the error
    #' @param data Any additional data associated with the error
    initialize = function(code=NULL, message=NULL, data=NULL) {
      self$code <- code
      self$message <- message
      self$data <- data
    }
  )
)

#' List of JSON-RPC 2.0 error codes
JsonRpcErrorCode <- list(

  # Invalid JSON was received by the server.
  # An error occurred on the server while parsing the JSON text.
  ParseError = -32700,

  # The JSON sent is not a valid Request object.
  InvalidRequest = -32600,

  # The method does not exist / is not available.
  MethodNotFound = -32601,

  # Invalid method parameter(s).
  InvalidParams = -32602,

  # Internal JSON-RPC error.
  InternalError = -32603,

  # Implementation defined server-errors...

  # Generic server error.
  ServerError = -32000,

  # Capability error
  CapabilityError = -32005
)
