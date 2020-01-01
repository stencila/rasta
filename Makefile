all: lint test cover build docs

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

# Run tests automatically on file changes
autotest:
	Rscript -e 'testthat::auto_test_package()'
	
# Run tests with coverage
cover:
	Rscript -e 'covr::package_coverage()'

check:
	Rscript -e 'devtools::check()'

# Build package
build:
	Rscript -e 'devtools::document(); warnings()'
	Rscript -e 'devtools::build()'

# Generate documentation
docs:
	Rscript -e 'devtools::document()'

# Install package
install: docs
	Rscript -e 'devtools::install()'

# Register Rasta as a Stencila executor
register: install
	Rscript -e 'rasta::register()'

# Clean up local development environment
clean:
	rm -rf rasta_*.tar.gz rasta.Rcheck
