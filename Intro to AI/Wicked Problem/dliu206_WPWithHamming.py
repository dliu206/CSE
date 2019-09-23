'''dliu206_WPWithHamming.py
David Liu - dliu206@uw.edu
A heuristic function for the Wicked Problem that counts the number of departments out of place.'''

from dliu206_WickedProblem_two import *


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
        if value < "200":
            counter += 1

    return counter


