'''dliu206_WPWithInverseAverage.py
David Liu - dliu206@uw.edu
A heuristic function for the Wicked Problem that inverses the averages the values of the given state.'''

from dliu206_WP_three import *


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
        counter += 1.0 / int(value)

    return 1.0 / (counter / NUM_CATEGORIES)


