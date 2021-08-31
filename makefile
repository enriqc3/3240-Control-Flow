examples: example_if.s

example_if.s: example_if.c
	gcc -Wall -O0 -S -o $@ $<

example_if.o: example_if.s
	gcc -Wall -O0 -c -o $@ $<

example_if.out: example_if.o
	gcc -Wall -O0 -o $@ $<

clean:
	rm -r -f example_if.s *.o
