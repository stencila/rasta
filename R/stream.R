#' Functions for encoding and decoding length prefixed messages over streams
#'
#' These functions implement the same protocol as used
#' by other Stencila executors (e.g. Executa and Pyla) for sending
#' messages using streams (e.g. standard input / output, TCP streams).
#' Essentially it implements the functionality in the Node.js package
#' [`length-prefixed-stream`](https://www.npmjs.com/package/length-prefixed-stream).
#'
#' - [`stream_read_message`]
#' - [`stream_write_message`]
#' - [`stream_read_varint`]
#' - [`stream_write_varint`]
#'
#' @name stream
#' @rdname stream
NULL

#' Read a length prefixed message from a stream.
#'
#' @param stream The name of the stream to read from. Defaults to `"stdin"`.
#' @param offset The offset from the start of the file to start reading from.
#' @param blocking Should the read be a blocking operation?
#' @param cpp Should the C++ implementation be used? Defaults to `TRUE`.
#' @returns The message as a string.
stream_read_message <- function(stream = "stdin", offset = -1, blocking = TRUE, cpp = TRUE) {
    if (cpp) {
        stream_read_message_cpp(stream, offset, blocking = blocking)
    } else {
        if (is.character(stream)) stream <- file(stream, open = "rb", blocking = blocking)
        if (offset > -1) seek(stream, 0, "start")
        message_length <- stream_read_varint(stream)
        if (message_length == 0) return("")
        bytes <- readBin(stream, raw(), n = message_length, size = 1)
        rawToChar(bytes)
    }
}

#' Write a length prefixed message to a stream.
#'
#' @param message The message to write.
#' @param stream The name of the stream to read from. Defaults to `"stdout"`.
#' @param offset The offset from the start of the file to start reading from.
#' @param cpp Should the C++ implementation be used? Defaults to `TRUE`.
#' @returns `TRUE` if the message was successfully written, `FALSE` otherwise.
stream_write_message <- function(message, stream = "stdout", offset = -1, cpp = TRUE) {
    if (cpp) {
        stream_write_message_cpp(message, stream, offset)
    } else {
        if (is.character(stream)) stream <- file(stream, open = "wb")
        if (offset > -1) seek(stream, 0, "start")
        bytes <- if (is.character(message)) charToRaw(message) else message
        stream_write_varint(stream, length(bytes))
        writeBin(bytes, stream, size = 1, useBytes = TRUE)
        flush(stream)
        TRUE
    }
}

msb <- as.integer(0x80)
rest <- as.integer(0x7F)
msb_all <- bitwNot(rest)

#' Read a `varint` from a stream
#'
#' @param stream The stream to read from
stream_read_varint <- function(stream) {
    # Implementation based on https://github.com/chrisdickinson/varint/blob/30e24d4/decode.js
    # and https://github.com/stencila/pyla/blob/22eb336/stencila/pyla/servers.py#L68
    result <- as.integer(0)
    shift <- as.integer(0)
    while (TRUE) {
        byte <- readBin(stream, raw(), n = 1, size = 1)
        if (length(byte) == 0) break
        int <- as.integer(byte)
        result <- result + bitwShiftL(bitwAnd(int, rest), shift)
        shift <- shift + 7
        if (byte < msb) break
    }
    result
}

#' Write a `varint` to a stream
#'
#' @param stream The stream to write to
#' @param value The value to write
stream_write_varint <- function(stream, value) {
    # Implementation based on https://github.com/chrisdickinson/varint/blob/30e24d4/encode.js
    while (bitwAnd(value, msb_all
    )) {
        int <- bitwOr(bitwAnd(value, 0xFF), msb)
        byte <- as.raw(int)
        writeBin(byte, stream, useBytes = TRUE)
        value <- bitwShiftR(value, 7)
    }
    int <- bitwOr(value, 0)
    byte <- as.raw(int)
    writeBin(byte, stream, useBytes = TRUE)
}
