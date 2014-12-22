#!/usr/bin/python

#############################################################################
# Simple exampes of map

names=["Mary", "Isla", "Sam"]
name_lengths = map(len, names)

print names
print name_lengths

nums=[0, 1, 2, 3, 4]
squares = map(lambda x: x * x, nums)

print nums
print squares

#############################################################################
#
#############################################################################
import random

names = ['Mary', 'Isla', 'Sam']
code_names = ['Mr. Pink', 'Mr. Orange', 'Mr. Blonde']

# unfunctional example
for i in range(len(names)):
    names[i] = random.choice(code_names)

print names


# Now here's a functional version
result=map(lambda name:random.choice(code_names), names)
print result

#############################################################################
# exercise to rewrite unfunctional code functionally
#############################################################################

names = ['Mary', 'Isla', 'Sam']

# unfunctional way
for i in range(len(names)):
    names[i] = hash(names[i])

print names

# functional way
result=map(hash, names)
print result
