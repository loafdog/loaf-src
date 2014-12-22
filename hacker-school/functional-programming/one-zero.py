#!/usr/bin/python

#############################################################################
def zero(s):
    if s[0] == "0":
        return s[1:]

#############################################################################
def one(s):
    if s[0] == "1":
        return s[1:]

#############################################################################
def rule_sequence_imperative(s, rules):
    for rule in rules:
        s = rule(s)
        if s == None:
            break

    return s

#############################################################################
def rule_sequence_recursive(s, rules):
    if s is None:
        return None

    if len(rules) < 1: 
        return s

    return rule_sequence_recursive(rules[0](s), rules[1:])

    
#############################################################################
# MAIN
#############################################################################

print rule_sequence_imperative('0101', [zero, one, zero])
# => 1

print rule_sequence_imperative('0101', [zero, zero])
# => None

print rule_sequence_recursive('0101', [zero, one, zero])
# => 1

print rule_sequence_recursive('0101', [zero, zero])
# => None


