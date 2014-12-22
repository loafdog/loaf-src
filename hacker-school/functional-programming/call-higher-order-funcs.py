#!/usr/bin/python

from pprint import pprint

#############################################################################
# call and higher order funcs


bands = [{'name': 'sunset rubdown', 'country': 'UK', 'active': False},
         {'name': 'women', 'country': 'Germany', 'active': False},
         {'name': 'a silver mt. zion', 'country': 'Spain', 'active': True}]

def pipeline_each(data, ops):
    return reduce(lambda res, op: map(op, res),
                  ops,
                  data)

def assoc(_d, key, value):
    from copy import deepcopy
    d = deepcopy(_d)
    d[key] = value
    return d

# THIS IS A HIGHER ORDER FUNC
def call(fn, key):
    def apply_fn(record):
        return assoc(record, key, fn(record.get(key)))

    return apply_fn

set_canada_as_country = call(lambda x: 'Canada', 'country')
strip_punctuation_from_name = call(lambda x: x.replace('.', ''), 'name')
capitalize_names = call(str.title, 'name')

result = pipeline_each(bands, [set_canada_as_country,
                               strip_punctuation_from_name,
                               capitalize_names])

print '\ncall'
pprint(result)

#############################################################################
# same way but less read-able
bands = [{'name': 'sunset rubdown', 'country': 'UK', 'active': False},
         {'name': 'women', 'country': 'Germany', 'active': False},
         {'name': 'a silver mt. zion', 'country': 'Spain', 'active': True}]

result = pipeline_each(bands, [call(lambda x: 'Canada', 'country'),
                               call(lambda x: x.replace('.', ''), 'name'),
                               call(str.title, 'name')])
print '\ncall 2'
pprint(result)


#############################################################################
#
#############################################################################

bands = [{'name': 'sunset rubdown', 'country': 'UK', 'active': False},
         {'name': 'women', 'country': 'Germany', 'active': False},
         {'name': 'a silver mt. zion', 'country': 'Spain', 'active': True}]

def extract_name_and_country(band):
    plucked_band = {}
    plucked_band['name'] = band['name']
    plucked_band['country'] = band['country']
    return plucked_band

result = pipeline_each(bands, [call(lambda x: 'Canada', 'country'),
                               call(lambda x: x.replace('.', ''), 'name'),
                               call(str.title, 'name'),
                               extract_name_and_country])
print '\nextract_name_and_country'
pprint(result)

# => [{'name': 'Sunset Rubdown', 'country': 'Canada'},
#     {'name': 'Women', 'country': 'Canada'},
#     {'name': 'A Silver Mt Zion', 'country': 'Canada'}]


#############################################################################
# Now try same thing but use a higher order func called pluck.  It
# takes a list of keys to extract from each record.

bands = [{'name': 'sunset rubdown', 'country': 'UK', 'active': False},
         {'name': 'women', 'country': 'Germany', 'active': False},
         {'name': 'a silver mt. zion', 'country': 'Spain', 'active': True}]

def pluck(keys):
    def pluck_fn(record):
        return reduce(lambda a, x:assoc(a, x, record[x]), 
                      keys,
                      {})

    return pluck_fn

result = pipeline_each(bands, [call(lambda x: 'Canada', 'country'),
                               call(lambda x: x.replace('.', ''), 'name'),
                               call(str.title, 'name'),
                               pluck(['name','country'])])

print '\npluck'
pprint(result)
