#include "../../src/stream.cpp"
#include <iostream>

int main (void) {
  std::string filename = "test-stream.tmp";

  // Single byte message
  stream_write_message("A", filename);
  assert(stream_read_message(filename) == "A");

  // Something a _little_ more interesting
  stream_write_message("Hello", filename);
  assert(stream_read_message(filename) == "Hello");

  // For message lengths <= 127, the varint is 1 byte
  std::string str127(127, 'a');
  stream_write_message(str127, filename);
  assert(stream_read_message(filename) == str127);

  // For message lengths >= 128, the varint is 2 bytes
  std::string str128(128, 'a');
  stream_write_message(str128, filename);
  assert(stream_read_message(filename) == str128);

  // Test varint sizes 1, 2, 3, 4 (beyond that requires over 34GB of memory)
  for (unsigned long base = 1; base < 5; base++) {
    const long size = std::pow(std::pow(2, base), 7);
    std::string message(size, 'a');
    stream_write_message(message, filename);
    std::string read = stream_read_message(filename);
    if (read.length() != size) {
      std::cerr << read.length() << " != " << size << std::endl;
    }
  }

  // Should return a empty string if no messages on the stream
  assert(stream_read_message(filename) == "");

  // Should return a empty string if stream does not exist
  assert(stream_read_message("does-not-exist") == "");

  // Cleanup
  remove(filename.c_str());
}
