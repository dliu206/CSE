David Liu
CSS 390 - Scripting
Autumn 2020


Assignment 5: Finite-State-Machine Generator

This program automates writing FSA code in C++ using Python.

Using the Machine class with the following methods:
	header(text): C++ code to pass through to the end of the file
	footer(text): C++ code to pass through to the end of the file
	state(state_name, action_string edge_list): declare a state
	edge(event_name, next_state, optional_action_string): declare a state transition
	gen(): generate the C++ code and write to standard output

you can create functional C++ code that simulates an FSA machine.

The two example files given as starter code named HOS.py and digit.py are two different
usages of the Machine class that creates functional FSA C++ code.

output.c is the output of digit.py when running with the Machine class from fsm.py
output1.c is the output of HOS.py when running with the Machine class from fsm.py

