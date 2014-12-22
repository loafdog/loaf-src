#!/usr/bin/python

from pprint import pprint

#############################################################################
# unfunctional way

bands = [{'name': 'sunset rubdown', 'country': 'UK', 'active': False},
         {'name': 'women', 'country': 'Germany', 'active': False},
         {'name': 'a silver mt. zion', 'country': 'Spain', 'active': True}]

def format_bands(bands):
    for band in bands:
        band['country'] = 'Canada'
        band['name'] = band['name'].replace('.', '')
        band['name'] = band['name'].title()

pprint(bands)
format_bands(bands)
print
pprint(bands)
# => [{'name': 'Sunset Rubdown', 'active': False, 'country': 'Canada'},
#     {'name': 'Women', 'active': False, 'country': 'Canada' },
#     {'name': 'A Silver Mt Zion', 'active': True, 'country': 'Canada'}]


#############################################################################
# functional way

bands = [{'name': 'sunset rubdown', 'country': 'UK', 'active': False},
         {'name': 'women', 'country': 'Germany', 'active': False},
         {'name': 'a silver mt. zion', 'country': 'Spain', 'active': True}]

def assoc(_d, key, value):
    from copy import deepcopy
    d = deepcopy(_d)
    d[key] = value
    return d

def set_canada_as_country(band):
    return assoc(band, 'country', "Canada")

def strip_punctuation_from_name(band):
    return assoc(band, 'name', band['name'].replace('.', ''))

def capitalize_names(band):
    return assoc(band, 'name', band['name'].title())

def pipeline_each1(data, ops):
    for op in ops:
        data=map(op, data)

    return data

def pipeline_each(data, ops):
    # plain wrong
    # return map(map(op, data), data)
    # return map(ops, map(op, data))

    # works but returns hash 3x, with dups.. why? um.. um.. not sure
    # why
    #
    # return map(lambda op: map(op, data), ops)

    # works!
    return reduce(lambda res, op: map(op, res),
                  ops,
                  data)

result=pipeline_each(bands, [set_canada_as_country,
                             strip_punctuation_from_name,
                             capitalize_names])
print '\npipeline_each'
pprint(result)

