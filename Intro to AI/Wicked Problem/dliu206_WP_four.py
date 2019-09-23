'''dliu206_WP_four.py
by David Liu

Project Option 1.
'''

PROBLEM_DESC=\
 ''' This file contains my problem formulation for the maintenance of a dictatorship country
in an alternate universe. Each month, you are able to allocate money towards a single department of your choice
since you are are high and mighty and don't want to share your wealth with the people appropriately.
There are 6 Department's that you can choose from to fund on a monthly basis:

Military Affairs
Food, Agriculture, & Environmental Affairs
Science and Technology (Education)
International and Internal Affairs (Government)
Housing

The goal to winning the game is to make each department's condition "Excellent" or "Ultra" by providing
funding to each department in a particular pattern so all departments have a positive condition.

A forbidden situation would be that any department would have a "Bad" condition in the next turn.

Conditions are : Bad, Satisfactory, Good, Excellent 
Where Bad is a rating [0, 100) 
Satisfactory is a rating [100, 200)
Good is a rating [200, 300)
Excellent is a rating [300, 400)
ULTRA is a rating [400, infinity)

In the formulation presented here, the computer will not let you make a move to such a forbidden situation, and it 
will only show you moves that could be executed "safely". Some of the methods have been taken 
from the starter code by Steven Tanimoto in Missionaries.py (Operator class)"
'''

import random

# Military
M = 0
# Food and Agriculture
F = 1
# Science
S = 2
# Government
G = 3
# Housing
H = 4

NUM_CATEGORIES = 6
class State():

  def __init__(self, d=None):
    if d==None:
      d = {'condition':[[0], [0], [0], [0], [0]]}
    self.d = d

  def edge_distance(self, s2):
    return 1.0

  def __eq__(self,s2):
    for state in ['condition']:
      if self.d[state] != s2.d[state]: return False
    return True

  def __str__(self):
    # Produces a textual description of a state.
    p = self.d['condition']
    txt = ""
    txt += "\nMilitary: " + txt_condition(p[M][0]) + " with value " + str(p[M][0])
    txt += "\nFood & Agriculture: " + txt_condition(p[F][0]) + " with value " + str(p[F][0])
    txt += "\nScience: " + txt_condition(p[S][0]) + " with value " + str(p[S][0])
    txt += "\nGovernment: " + txt_condition(p[G][0]) + " with value " + str(p[G][0])
    txt += "\nHousing: " + txt_condition(p[H][0]) + " with value " + str(p[H][0])
    return txt

  def __hash__(self):
    return (self.__str__()).__hash__()

  def copy(self):
    copy = State({})
    copy.d['condition']=[self.d['condition'][obj][:] for obj in [M, F, S, G, H]]
    return copy

  def can_move(self,m,f,s,g,h):
    '''Tests whether it's legal to move the boat and take
    the chicken, fox, farmer, and grain.'''
    condition = self.d['condition']
    if condition[M][0] < 100 or condition[F][0] < 100 or \
            condition[S][0] < 100 or condition[G][0] < 100 or condition[H][0] < 100:
        return False
    military_available = condition[M][0] + m
    farm_available = condition[F][0] + f
    science_available = condition[S][0] + s
    government_available = condition[G][0] + g
    housing_available = condition[H][0] + h

    if military_available < 100 or farm_available < 100 or science_available < 100 or \
            government_available < 100 or housing_available < 100:
        return False

    return True


  def move(self,m,f,s,g,h):
    '''Assuming it's legal to make the move, this computes
     the new state resulting from the departments turn.'''
    news = self.copy()      # start with a deep copy.
    condition = news.d['condition']
    condition[M][0] += m
    condition[F][0] += f
    condition[S][0] += s
    condition[G][0] += g
    condition[H][0] += h
    return news


def txt_condition(value):
  if value < 100:
    return "Bad"
  elif value < 200:
    return "Satisfactory"
  elif value < 300:
    return "Good"
  else:
    return "Excellent"

def txt_comb(m, f, s, g, h):
  if m == 100:
    return "the Military"
  elif f == 100:
    return "the Food & Agriculture"
  elif s == 100:
    return "the Science"
  elif g == 100:
    return "the Government"
  elif h == 100:
    return "the Housing"
  return "no"

def goal_test(s):
  'If the chicken, fox, and grain are all on the right side, then s is in the goal state.'
  c = s.d['condition']
  return c[M][0] >= 300 and c[F][0] >= 300 and c[S][0] >= 300 and c[G][0] >= 300 and c[H][0] >= 300

def goal_message(s):
  return "Congratulations on successfully making a well-rounded dictatorship!"

#<INITIAL_STATE>
CREATE_INITIAL_STATE = lambda : State(d={'condition':[[100], [100], [100], [100], [100]]})
#</INITIAL_STATE>

#<OPERATORS>
# 5 parameters M, F, S, G, H
combinations = [(100, -50, 25, 0, 0), (0, 100, 0, 0, 50), (0, 0, 100, -50, 0),
                   (0, -50, -50, 100, 0), (-50, 0, 0, 0, 100), (-25, -25, -25, -25, -25)]

OPERATORS = [Operator("Funded the " + txt_comb(m, f, s, back_cost, h) + " department.",
                      lambda s, m1=m, f1=f, s1=s, g1=back_cost, h1=h:s.can_move(m1, f1, s1, g1, h1),
                      lambda s, m1=m, f1=f, s1=s, g1=back_cost, h1=h: s.move(m1, f1, s1, g1, h1))
             for (m, f, s, back_cost, h) in MC_combinations]
#</OPERATORS>
