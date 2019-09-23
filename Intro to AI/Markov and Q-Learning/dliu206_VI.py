'''dliu206_VI.py

Value Iteration for Markov Decision Processes.
'''


def student_name():
   return "Liu, David"

Vk = {}
QVal = {}

def VI_one(S, A, T, R, gamma, Vk):
   global QVal, Vk
   delta = float("-inf")

   for state in S:
      if state not in Vk:
         Vk[state] = 0
      if state not in Vk:
         Vk[state] = 0

   for state in S:
      temp = Vk[state]
      for action in A:
         total = 0
         for endState in S:
            probability = T(state, action, endState)
            reward = R(state, action, endState)
            total = total + probability * (reward + (gamma * Vk[endState]))
            Vk[state] = max(Vk[state], total)
         QVal[(state, action)] = total
      delta = max(delta, abs(temp - Vk[state]))

   return (Vk, delta)

def get_QVal(S, A):
   global QVal

   if len(QVal) == 0:
      for state in S:
          for action in A:
             QVal[state, action] = 0.0

   return QVal

Policy = {}
def get_policy(S, A):
   global Policy, QVal

   if len(QVal) == 0:
      get_QVal(S, A)

   for state in S:
      q = 0
      for action in A:
         if q < QVal[(state, action)]:
            q = QVal[(state, action)]
            Policy[state] = action

   return Policy

def use_policy(s):
   global Policy
   return Policy[s]


