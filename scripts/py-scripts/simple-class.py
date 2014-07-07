#!/usr/bin/python

class Simple:
    def m1(self):
        return True
    def m2(self, isTrue):
        return isTrue

if __name__ == '__main__':

    s = Simple()
    s.m1()
    f1 = s.m1
    s.m2(False)
