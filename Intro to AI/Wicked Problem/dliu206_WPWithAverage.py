'''dliu206_WPWithAverage.py
David Liu - dliu206@uw.edu
A heuristic function for the Wicked Problem that averages the values of the given state.'''

from dliu206_WickedProblem_four import *


# Count the number of departments out of place
def h(s):
    target = s.d['condition']
    temp_string = ""
    for a in str(target):
        if a == '\n':
            temp_string += ","
        elif a != " " and a != "]" and a != "[":
            temp_string += a
    result = temp_string.split(",")

    counter = 0
    for value in result:
        counter += int(value)

    return counter / NUM_CATEGORIES * 1.0


