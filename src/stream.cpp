/**
 * C++ implementations of `stream_write_message` and
 * `stream_read_message` that write and read length
 * prefixed messages to streams. See `stream.R` for
 * more docs and R implementation.
 * 
 * This C++ implementation is mainly to workaround the
 * inability to write binary data to stdout from R.
 * With `stdin` it is possible to use `file("stdin", "rb")`
 * to read binary data. Unfortunately, we can't do the same with stdout 
 * - it is always a text connection, and in the past we have had to
 * resort to piping to another program ie. `pipe("cat", "rb")`, which
 * is inefficient and slow. See https://stackoverflow.com/questions/7422575/how-to-write-raw-type-bytes-to-stdout
 * 
 * In addition, this implementation is roughly twice the speed
 * of the same R implementation. See `../tests/bench/bench-stream.R`.
 */

#include <cassert>
#include <cmath>
#include <cstdio>
#include <iostream>
#include <map>
#include <string>
#include <vector>

// Get the length of a varint for an integer.
// 
// These numbers are 2^7, 4^7, 8^7, ...
int varint_length(unsigned long n) {
  return (
      n < 128 ? 1
    : n < 16384 ? 2
    : n < 2097152 ? 3
    : n < 268435456 ? 4
    : n < 34359738368 ? 5
    : n < 4398046511104 ? 6
    : n < 562949953421312 ? 7
    : n < 72057594037927936 ? 8
    : n < 9223372036854775808U ? 9
    : 10
  );
}

//' Write a length prefixed message to a stream
//' 
//' @param message The message to write
//' @param stream The name of the stream to read from. Defaults to `stdout`.
//' @param offset The offset from the start of the file to start reading from.
//' @returns `TRUE` if the message was successfully written, `FALSE` otherwise.
// [[Rcpp::export("stream_write_message_cpp")]]
bool stream_write_message(std::string message, std::string stream = "stdout", long offset = -1) {
  // Calculate the total length of the message including 
  // the length prefix and allocate a vector of bytes
  unsigned long message_length = message.length();
  const unsigned long total_length = varint_length(message_length) + message_length;
  std::vector<char> bytes(total_length);

  // Encode the varint
  unsigned long index = 0;
  while (message_length & ~0x7F) {
    bytes[index++] = (message_length & 0xFF) | 0x80;
    message_length >>= 7;
  }
  bytes[index] = message_length;

  // Encode the message
  bytes.insert(bytes.begin() + index + 1, message.begin(), message.end());

  // Get the stream
  static std::map<std::string, FILE*> file_pointers;
  FILE* file_pointer = stdout;
  if (stream != "stdout") {
    std::map<std::string, FILE*>::iterator it = file_pointers.find(stream);
    if (it != file_pointers.end()) file_pointer = it->second;
    else {
      file_pointer = std::fopen(stream.c_str(), "wb");
      if (!file_pointer) {
        std::perror("Error in stream_read_message");
        return false;
      }
      file_pointers[stream] = file_pointer;
    }
    if (offset > -1) {
      // Go to the position and turn off buffering
      std::fseek(file_pointer, offset, SEEK_SET);
      std::setbuf(file_pointer, NULL);
    }
  }

  // Write message to it
  size_t bytes_written = std::fwrite(bytes.data(), sizeof(char), total_length, file_pointer);
  assert(bytes_written == total_length);
  std::fflush(file_pointer);
  return true;
}

//' Read a length prefixed message from a stream.
//' 
//' @param stream The name of the stream to read from. Defaults to `stdin`.
//' @param offset The offset from the start of the file to start reading from.
//' @returns The message as a string.
// [[Rcpp::export("stream_read_message_cpp")]]
std::string stream_read_message(std::string stream = "stdin", long offset = -1) {
  // Get the stream
  static std::map<std::string, FILE*> file_pointers;
  FILE* file_pointer = stdin;
  if (stream != "stdin") {
    std::map<std::string, FILE*>::iterator it = file_pointers.find(stream);
    if (it != file_pointers.end()) file_pointer = it->second;
    else {
      file_pointer = std::fopen(stream.c_str(), "rb");
      if (!file_pointer) {
        std::perror("Error in stream_read_message");
        return "";
      }
      file_pointers[stream] = file_pointer;
    }
    if (offset > -1) {
      // Go to the position and turn off buffering
      std::fseek(file_pointer, offset, SEEK_SET);
      std::setbuf(file_pointer, NULL);
    }
  }

  // Read varint from it
  unsigned long message_length = 0;
  int shift = 0;
  char byte;
  unsigned long value;
  do {
    size_t bytes_read = std::fread(&byte, sizeof(char), 1, file_pointer);
    if (bytes_read != 1) {
      if (std::ferror(file_pointer)) std::perror("Error in stream_read_message");
      return "";
    }
    // It's necessary to convert the byte to a long!
    value = byte;
    message_length += (value & 0x7F) << shift;
    shift += 7;
  } while (value >= 0x80);

  // Read the message from it
  std::string message(message_length, 0);
  size_t bytes_read = std::fread(&message[0], sizeof(char), message_length, file_pointer);
  if (bytes_read != message_length) {
    // Log errors and return empty message
    if (std::ferror(file_pointer)) std::perror("Error in stream_read_message");
    else if (std::feof(file_pointer)) std::cerr << "Error in stream_read_message: Unexpected end of file\n";
    return "";
  }
  return message;
}
