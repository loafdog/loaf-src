#!/usr/bin/python


# Filter takes a function and collection and returns a collection of
# every item for which func returned True. Use it and map/reduce to
# rewrite functionally

#############################################################################
# unfunctional way. 

people = [
    {'name': 'Mary', 'height': 160},
    {'name': 'Isla', 'height': 80},
    {'name': 'Sam'}
]

height_total = 0
height_count = 0
for person in people:
    if 'height' in person:
        height_total += person['height']
        height_count += 1

if height_count > 0:
    average_height = height_total / height_count

    print average_height
    # => 120

print
#############################################################################
# functional way. 


p1=filter(lambda person: 'height' in person, people)
print p1
if len(p1) > 0:
    total=reduce(lambda a, person: a + person['height'], p1, 0)
    print total
    print total/len(p1)
