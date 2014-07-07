#!/usr/bin/python

def f1():
    x = "i am x"
    print x

def f2():
    y = "i am y"
    print y
    print z

def f3():
    z = "i am z"
    f2()

if __name__ == '__main__':
    f1()
    f3()
    #f2()

