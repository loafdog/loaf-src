#!/usr/bin/python

def cheeseshop(kind, *arguments, **keywords):
    print "-- Do you have any", kind, "?"
    print "-- I'm sorry, we're all out of", kind
    for arg in arguments:
        print arg
    print "-" * 40
    keys = sorted(keywords.keys())
    for kw in keys:
        print kw, ":", keywords[kw]


def cheeseshop2(kind, *arguments, **keywords):
    print "-- Do you have any", kind, "?"
    print "-- I'm sorry, we're all out of", kind
    for arg in arguments:
        print arg
    print "-" * 40
    keys = keywords.keys()
    for kw in keys:
        print kw, ":", keywords[kw]


def test_args1():
    # cannot put keyword arg(kwarg) before non-key work arg. Get a syntax
    # error exception. If i try to catch it script still exits.. ?
    print "="*40
    try:
        cheeseshop("Limburger",
#                   shopkeeper='Michael Palin',
                   "It's really very, VERY runny, sir.")
    #except SyntaxError:
    except:
        print "exception"


def test_args2():
    print "="*40
    cheeseshop("Limburger",
               "It's very runny, sir.",
               "It's really very, VERY runny, sir.",
               a='Michael Palin',
               c="John Cleese",
               b="Cheese Shop Sketch")

    # kwargs will be printed in undefined order b/c they are not
    # sorted in v2 
    print "="*40
    cheeseshop2("Limburger",
               "It's very runny, sir.",
               "It's really very, VERY runny, sir.",
               a='Michael Palin',
               c="John Cleese",
               b="Cheese Shop Sketch")

if __name__ == '__main__':
    print "here"
    test_args2()
#    test_args1()

