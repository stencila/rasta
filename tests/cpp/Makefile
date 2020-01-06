all: $(patsubst %.cpp,%.run,$(wildcard *.cpp))

%.run: %.cpp
	g++ $< -o $*
	./$*
	rm $*
