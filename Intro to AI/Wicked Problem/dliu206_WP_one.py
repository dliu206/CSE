'''dliu206_WP_one.py
by David Liu

Project Option 1
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

The goal to winning the game is to make each department's condition "Good" or "Excellent" by providing
funding to each department in a particular pattern so all departments have a positive condition.

A forbidden situation would be that any department would have a "Bad" condition in the next turn.

Conditions are : Bad, Satisfactory, Good, Excellent 
Where Bad is a rating [0, 100) 
Satisfactory is a rating [100, 200)
Good is a rating [200, 300)
Excellent is a rating [300, infinity]

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

NUM_CATEGORIES = 5
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
    txt += "\nMilitary: " + txt_comb(p[M][0]) + " with value " + str(p[M][0])
    txt += "\nFood & Agriculture: " + txt_comb(p[F][0]) + " with value " + str(p[F][0])
    txt += "\nScience: " + txt_comb(p[S][0]) + " with value " + str(p[S][0])
    txt += "\nGovernment: " + txt_comb(p[G][0]) + " with value " + str(p[G][0])
    txt += "\nHousing: " + txt_comb(p[H][0]) + " with value " + str(p[H][0])
    return txt

  def __hash__(self):
    return (self.__str__()).__hash__()

  def copy(self):
    # Performs an appropriately deep copy of a state,
    # for use by operators in creating new states.
    news = State({})
    news.d['condition']=[self.d['condition'][obj][:] for obj in [M, F, S, G, H]]
    return news

  def can_move(self,m,f,s,g,h):
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
    copy = self.copy()      # start with a deep copy.
    condition = copy.d['condition']
    condition[M][0] += m
    condition[F][0] += f
    condition[S][0] += s
    condition[G][0] += g
    condition[H][0] += h
    return copy


def txt_comb(value):
  if value < 100:
    return "Bad"
  elif value < 200:
    return "Satisfactory"
  elif value < 300:
    return "Good"
  else:
    return "Excellent"


def txt_combination(m,f,s,g,h):
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
  c = s.d['condition']
  return c[M][0] >= 200 and c[F][0] >= 200 and c[S][0] >= 200 and c[G][0] >= 200 and c[H][0] >= 200


def goal_message(s):
  return "Congratulations on successfully making a well-rounded dictatorship!"

CREATE_INITIAL_STATE = lambda : State(d={'condition':[[100], [100], [100], [100], [100]]})
#</INITIAL_STATE>

#<OPERATORS>
# 5 parameters M, F, S, G, H
MC_combinations = [(100, random.randint(-50, 0), random.randint(0, 50), 0, 0), (0, 100, 0, 0, random.randint(0, 50)),
                   (0, 0, 100, random.randint(-50, 0), 0), (0, random.randint(-50, 0), random.randint(-50, 0), 100, 0),
                   (random.randint(-50, 0), 0, 0, 0, 100),
                   (random.randint(-25, 0), random.randint(-25, 0), random.randint(-25, 0),
                    random.randint(-25, 0), random.randint(-25, 0))]


# mfsgh
OPERATORS = [Operator("Funded " + txt_combination(m, f, s, back_cost, h) + " department.",
                      lambda s, m1=m, f1=f, s1=s, g1=back_cost, h1=h:s.can_move(m1, f1, s1, g1, h1),
                      lambda s, m1=m, f1=f, s1=s, g1=back_cost, h1=h: s.move(m1, f1, s1, g1, h1))
             for (m, f, s, back_cost, h) in MC_combinations]
