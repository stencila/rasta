library(bench)
library(stencilaprocessor)

# Create mmap connection with other
# end echoing in a separate R session

# mmap
mmap_conn <- MmapConnection$new()
mmap_server <- future::multiprocess({
  conn <- MmapConnection$new(mmap_conn$path)
  conn$listen(conn$write)
})

mmap <- function(payload) {
  mmap_conn$write(payload)
  length(mmap_conn$read())
}

# Pipes
pipe1 <- tempfile()
pipe2 <- tempfile()
system(paste("mkfifo", pipe1))
system(paste("mkfifo", pipe2))
reader1 <- fifo(pipe1, open = "rb", blocking = FALSE)
reader2 <- fifo(pipe2, open = "rb", blocking = FALSE)
writer1 <- fifo(pipe1, open = "wb", blocking = FALSE)
writer2 <- fifo(pipe2, open = "wb", blocking = FALSE)
pipe_conn <- StreamConnection$new(reader1, writer2)
#pipe_server <- future::multiprocess({
  conn <- StreamConnection$new(reader2, writer1)
  #conn$listen(conn$write)
#})

pipe <- function(payload) {
  pipe_conn$write(payload)
  payload <- conn$read()
  conn$write(payload)
  length(pipe_conn$read())
}

# TCP
tcp_port <- 2345
tcp_server <- future::multiprocess({
  socket <- socketConnection(
    port = tcp_port,
    blocking = TRUE,
    server = TRUE,
    open = "r+b"
  )
  conn <- StreamConnection$new(socket)
  conn$listen(conn$write)
})
Sys.sleep(1)
socket <- socketConnection(
  port = tcp_port,
  blocking = TRUE,
  open = "r+b"
)
tcp_conn <- StreamConnection$new(socket)

tcp <- function(payload) {
  tcp_conn$write(payload)
  length(tcp_conn$read())
}

results <- bench::press(
  size = seq(2, 26, 2), {
    payload <- raw(size^2)
    bench::mark(
      mmap = mmap(payload),
      pipe = pipe(payload),
      tcp = tcp(payload)
    )
  }
)

mmap_conn$close()

tools::pskill(mmap_server$job$pid, signal = tools::SIGKILL)
#tools::pskill(pipe_server$job$pid, signal = tools::SIGKILL)
tools::pskill(tcp_server$job$pid, signal = tools::SIGKILL)

results$protocol <-  as.character(unlist(results$expression))

#library(ggplot2)
#ggplot(results, aes(x=log(size), y=median, colour=protocol)) + geom_point()

results
