#!/usr/bin/env python

import random
import threading

def find_index(a, n):
   i = 0
   while a[i] < n and i < len(a):
      i += 1
   return i

def merge(a, b):
   global out

   for i in range(len(a)):
      if a[i] < b[0]:
         out[i] = a[i]
      elif a[i] > b[-1]:
         out[i+len(b)] = a[i]
      else:
         out[i+find_index(b, a[i])] = a[i]
   return

num_threads = 2
num_items = 32
ipt = num_items / num_threads

sorted = range(num_items)
unsorted = list(sorted)
random.shuffle(unsorted)

out = [None for i in unsorted]

partial_sorts = [unsorted[i*ipt:(i+1)*ipt] for i in range(num_threads)]
for i in range(len(partial_sorts)):
   partial_sorts[i].sort()
   print partial_sorts[i]

merge(partial_sorts[0], partial_sorts[1])
merge(partial_sorts[1], partial_sorts[0])

print out

