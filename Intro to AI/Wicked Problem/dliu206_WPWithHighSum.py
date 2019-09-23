'''dliu206_WPWithHighSum.py
David Liu - dliu206@uw.edu
A heuristic function for the Wicked Problem that sums and accounts for highest total value.'''

from dliu206_WP_four import *


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

    return counter


