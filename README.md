# R Processor

> A R package implementing a [stencil](https://github.com/stencila/schema#readme) [`Processor`](https://github.com/stencila/schema#processor) class

![Status](https://img.shields.io/badge/status-experimental-orange.svg)
[![Build](https://travis-ci.org/stencila/r-processor.svg?branch=master)](https://travis-ci.org/stencila/r-processor)
[![Code coverage](https://codecov.io/gh/stencila/r-processor/branch/master/graph/badge.svg)](https://codecov.io/gh/stencila/r-processor)
[![Community](https://img.shields.io/badge/join-community-green.svg)](https://community.stenci.la)
[![Chat](https://badges.gitter.im/stencila/stencila.svg)](https://gitter.im/stencila/stencila)

> ⚠ This package is in early development. It implements a R `Processor` class that exposes the API described in the [schema](https://github.com/stencila/schema#readme) repo for processing executable documents meeting that schema (_aka_ stencils). Currently , it's just a parking spot for R code extracted from the schema repo but we plan to start work on it again in the coming months.

## Notes

### Dependencies

For a package to be on CRAN, all of its dependencies must also be on CRAN. For this reason, we avoid any package dependencies that are not available on CRAN.

|         | Server      | Client
----------|-------------|-------------
Mmap      |             |
Pipe      |             |
TCP       | `base`      | `base`
HTTP      | `httpuv`    | `httr`
WebSocket | `httpuv`    | no


## Transport classes that are not implemented

### `PipeServer`

`httpuv` has `startPipeServer` which supports HTTP over Windows Named Pipes and Unix Domain Sockets. However, it does not support raw binary communications over these.

### `WebSocketClient`

The [`websocket`](https://github.com/rstudio/websocket) package provides a WebSocket client backed by the [websocketpp](https://github.com/zaphoyd/websocketpp) C++ library. However it is not currently available on CRAN.
