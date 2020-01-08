#include <sys/types.h>
#include <sys/stat.h>
#include <string>

//' Create a named pipe
//' @param name Name (i.e. file path) for the pipe
// [[Rcpp::export]]
bool pipe_make(std::string name) {
  mkfifo(name.c_str(), 0600);
}
