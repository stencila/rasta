all: $(patsubst %.R,%.out,$(wildcard *.R))

%.out: %.R FORCE
	Rscript -e 'source("$<", echo=TRUE)' > $@

FORCE:
