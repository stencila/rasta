# 🌴 Rasta

#### R interpreter for Stencila executable documents

[![Build Status](https://dev.azure.com/stencila/stencila/_apis/build/status/stencila.rasta?branchName=master)](https://dev.azure.com/stencila/stencila/_build/latest?definitionId=12&branchName=master)
[![Code coverage](https://codecov.io/gh/stencila/rasta/branch/master/graph/badge.svg)](https://codecov.io/gh/stencila/rasta)
[![CRAN](https://www.r-pkg.org/badges/version-last-release/rasta)](https://cran.r-project.org/web/packages/rasta/)
[![Docs](https://img.shields.io/badge/docs-latest-blue.svg)](https://stencila.github.io/rasta/)

## Install

Rasta is available as a R package. It isn't on CRAN yet, but you can install it from this repository using the [`remotes`](https://github.com/r-lib/remotes) package,

```r
remotes::install_github("stencila/rasta")
```

## Use

Register Rasta so that it can be discovered by other executors on your machine,

```r
rasta::register()
```

If you have [`executa`](https://github.com/stencila/executa) installed globally, you can then run Rasta using the `execute` command and specifying `r` as the starting language,

```bash
executa execute --repl --lang r
```

## Develop

Get started by cloning this repository,

```bash
git clone git@github.com:stencila/rasta
cd rasta
```

Then install the necessary development dependencies,

```bash
make setup
```

Most development tasks can be run from R, using `make` shortcuts, or RStudio keyboard shortcuts.

Task                                                    | `make`                | R/RStudio       |
------------------------------------------------------- |-----------------------|-----------------|
Install development dependencies                        | `make setup`          | `devtools::install_dev_deps()`
Run linting                                             | `make lint`           | `lintr::lint_package()`
Run R tests                                             | `make test-r`         | `devtools::test()` or `Ctrl+Shift+T`
Run C++ tests                                           | `make test-cpp`       |
Run all tests                                           | `make test`
Run tests with coverage                                 | `make cover`          | `covr::package_coverage()`
Run benchmarks                                          | `make bench`          |
Build documentation                                     | `make docs`           |
Check the package                                       | `make check`          | `Ctrl+Shift+E`
Build                                                   | `make build`          | `Ctrl+Shift+B`
Clean                                                   | `make clean`          |

### Testing

Unit tests live in the `tests` folder. Most of the tests are written using the `testthat` package. When writing regression tests for a specific issues, please name the test file accordingly e.g. `tests/testthat/test-issue-1.R`. There is also a `tests/cpp` folder for C++ tests and a `tests/bench` folder for benchmarking.

### Documentation

Documentation is written using `roxygen2` and the documentation site is generated by `pkgdown` into the `docs` folder and published on GitHub pages at https://stencila.github.io/rasta/.

### Continuous integration

Tests are run on [Azure Pipelines](https://dev.azure.com/stencila/stencila/_build?definitionId=12) and code coverage tracked at [Codecov](https://codecov.io/gh/stencila/rasta).

## Notes

- This package has two functions, `stream_read_message` and `stream_write_message`, for reading and writing length prefixed messages from/to streams. These functions are implemented in both R and C++ and there is benchmarking code to compare their performance (run `make bench` and look for the outputs in `tests/bench`). The C++ implementations are 2-3 times faster. However, the times involved are small (<100µs for 10k messages) and having C++ code does add complexity and a dependency (`Rcpp`). Given that, we may remove the C++ implementations in the future.

- This package provides a `StdioServer` class which implements Stencila's execution API over standard input / output streams. It is analogous to the [`StdioServer`](https://github.com/stencila/executa/blob/v1.14.0/src/stdio/StdioServer.ts) class implemented in Typescript in the `stencila/executa` package. A previous version of this repository implemented a [`PipeServer`](https://github.com/stencila/rasta/blob/v0.7.1/R/pipe-server.R) class which used named pipes as the transport. However, this was not used in production, and so in the interest of keeping the code base as simple as possible, was removed. This note is intended for developers who might find a need to use the API over named pipes in the future.
 