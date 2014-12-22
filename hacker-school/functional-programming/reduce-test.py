#!/usr/bin/python


#############################################################################
#
#############################################################################

sum = reduce(lambda a, x: a + x, [0, 1, 2, 3, 4])

print sum
# => 10


#############################################################################
#
#############################################################################

sentences = ['Mary read a story to Sam and Isla.',
             'Isla cuddled Sam.',
             'Sam chortled.']

# unfunctional way
sam_count = 0
for sentence in sentences:
    sam_count += sentence.count('Sam')

print sam_count
# => 3

# functional way. Note add 3rd arg to map to init a to zero. w/o that
# arg a is init'ed to first array item (a str type) and first time
# thru loop you get exception b/c of trying to add str and int types.

sam_count=reduce(lambda a, sentence: a + sentence.count('Sam'), sentences, 0)
print sam_count
