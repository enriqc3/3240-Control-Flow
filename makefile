examples: example_if.s

example_if.s: example_if.c
	gcc -Wall -O0 -S -o example_if.s $<

clean:
	rm -r -f example_if.s
