# 🌴 Rasta

#### R interpreter for Stencila executable documents

[![Build Status](https://travis-ci.org/stencila/rasta.svg?branch=master)](https://travis-ci.org/stencila/rasta)
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

Most development tasks can be run from R, using `make` shortcuts, or RStudio keyboard shortcuts.

Task                                                    | `make`                | R/RStudio       |
------------------------------------------------------- |-----------------------|-----------------|
Install development dependencies                        | `make setup`          | 
Run linting                                             | `make lint`           | `lintr::lint_package()`
Run R tests                                             | `make test-r`           | `devtools::test()` or `Ctrl+Shift+T`
Run C++ tests                                           | `make test-cpp`       |
Run all tests                                           | `make test`
Run tests with coverage                                 | `make cover`          | `covr::package_coverage()`
Run benchmarks                                          | `make bench`          |
Build documentation                                     | `make docs`           |
Check the package                                       | `make check`          | `Ctrl+Shift+E`
Build                                                   | `make build`          | `Ctrl+Shift+B`
Clean                                                   | `make clean`          |

### Testing

Unit tests live in the `tests` folder. Most of the tests are written using the `testthat` package. When writing regression tests for a specific issues, please name the test file accordingly e.g. `tests/testthat/test-issue-1.R`. There is also a `tests/cpp` folder for C++ tests and a `tests/bench` folder for bechmarking.

### Documentation

Documentation is written using `roxygen2` and the documentation site is generated by `pkgdown` into the [`docs`](docs) folder and published on Github pages.

### Continuous integration

Tests are run on [Travis](https://travis-ci.org/stencila/rasta) and code coverage tracked at [Codecov](https://codecov.io/gh/stencila/rasta).
