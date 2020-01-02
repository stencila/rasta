# 🌴 Rasta

#### R interpreter for Stencila executable documents

[![Build Status](https://travis-ci.org/stencila/rasta.svg?branch=master)](https://travis-ci.org/stencila/rasta)
[![Code coverage](https://codecov.io/gh/stencila/rasta/branch/master/graph/badge.svg)](https://codecov.io/gh/stencila/rasta)
[![CRAN](https://www.r-pkg.org/badges/version-last-release/rasta)](https://cran.r-project.org/web/packages/rasta/)
[![Docs](https://img.shields.io/badge/docs-latest-blue.svg)](https://stencila.github.io/rasta/)

## Install

Rasta is available as a R package. It isn't on CRAN yet, but you can install it from this repository using the [`devtools`](https://github.com/hadley/devtools) package,

```r
devtools::install_github("stencila/rasta")
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
Run tests                                               | `make test`           | `devtools::test()` or `Ctrl+Shift+T`
Run tests with coverage                                 | `make cover`          | `covr::package_coverage()`
Build documentation                                     | `make docs`           |
Check the package                                       | `make check`          | `Ctrl+Shift+E`
Build                                                   | `make build`          | `Ctrl+Shift+B`
Clean                                                   | `make clean`          |

### Testing

Unit tests live in the `tests` folder and are written using `testthat`. To run test files individually, in R use `test_file`:

```r
library(testthat)
testthat::test_file(system.file("tests/testthat/test-r-context.R",package="stencila"))
```

### Documentation

Documentation is written using `roxygen2` and the documentation site is generated by `pkgdown` into the [`docs`](docs) folder and published on Github pages.

### Continuous integration

Tests are run on [Travis](https://travis-ci.org/stencila/rasta) and code coverage tracked at [Codecov](https://codecov.io/gh/stencila/rasta).
