#include <sys/types.h>
#include <sys/stat.h>
#include <cstdio>
#include <string>

//' Create a named pipe
//' @param name Name (i.e. file path) for the pipe
// [[Rcpp::export]]
bool pipe_make(std::string name) {
  int error = mkfifo(name.c_str(), 0600);
  if (error != 0) {
    std::perror("Error in pipe_make");
    return false;
  }
  return true;
}
