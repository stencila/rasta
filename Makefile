all: setup lint test cover bench integ build docs

# Setup the local development environment
setup:
	Rscript -e "install.packages('devtools')"
	Rscript -e "devtools::install_github(c('jimhester/lintr', 'klutometis/roxygen', 'r-lib/bench', 'r-lib/covr', 'r-lib/testthat'))"

# Do linting
lint:
	Rscript -e 'lintr::lint_package()'

# Run tests
test:
	Rscript -e 'devtools::test()'
	
# Run tests with coverage
cover:
	Rscript -e 'covr::package_coverage()'
	
# Run benchmarks
bench: install
	cd tests/bench && \
	Rscript connections.R && \
	Rscript encoders.R

# Build package
build:
	R CMD build . && R CMD check *.tar.gz
.PHONY: build

# Generate documentation
docs:
	Rscript -e 'devtools::document()'

# Install package
install: docs
	Rscript -e 'devtools::install()'

# Clean up local development environment
clean:
	rm -rf stencilaprocessor_*.tar.gz stencilaprocessor.Rcheck
