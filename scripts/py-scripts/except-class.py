#!/usr/bin/python

class B:
    pass
class C(B):
    pass
class D(C):
    pass


for c in [B, C, D]:
    try:
        raise c()
    except D:
        print "D"
    except C:
        print "C"
    except B:
        print "B"

for c in [B, C, D]:
    try:
        raise c()
    except B as b:
        print "B ",str(b),str(B)
# every exception will be caught by B block. 

for c in [B, C, D]:
    try:
        raise c()
    except D:
        print "D"
    except C:
        print "C"
# exception will be generated here because when you raise B() there is
# no except B line.  You can't catch exceptions from base class using
# derived classes
