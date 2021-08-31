examples: example_if.s example_switch.s example_while.s lab_control_flow.s

lab_control_flow.s: lab_control_flow.c
	gcc -Wall -O0 -S -o $@ $<

lab_control_flow.o: lab_control_flow.s
	gcc -Wall -O0 -c -o $@ $<

lab_control_flow.out: lab_control_flow.o
	gcc -Wall -O0 -o $@ $<

example_if.s: example_if.c
	gcc -Wall -O0 -S -o $@ $<

example_if.o: example_if.s
	gcc -Wall -O0 -c -o $@ $<

example_if.out: example_if.o
	gcc -Wall -O0 -o $@ $<

example_switch.s: example_switch.c
	gcc -Wall -O0 -S -o $@ $<

example_switch.o: example_switch.s
	gcc -Wall -O0 -c -o $@ $<

example_switch.out: example_switch.o
	gcc -Wall -O0 -o $@ $<

example_while.s: example_while.c
	gcc -Wall -O0 -S -o $@ $<

example_while.o: example_while.s
	gcc -Wall -O0 -c -o $@ $<

example_while.out: example_while.o
	gcc -Wall -O0 -o $@ $<

clean:
	rm -r -f *.o example_if.s example_switch.s example_while.s
