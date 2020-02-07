# Record test log entries so that they can be tested for
# and so logs do not pollute test output
test_logs <- list()
set_log_handler(function(data) test_logs <<- c(test_logs, list(data)))
last_log <- function() rev(test_logs)[[1]]
