
; adds 4 and 10 
(+ (- 5 1 ) (+ 3 7))

; creates a list of (1 5)
(list 1 (+ 2 3))

; 1 is not a list so print 7
(if (listp 1) (+ 1 2) (+ 3 4))

; create a list. first is and stmt which checks if 3 is a list. it is
; not so stop eval'ing and return nil.  Next in list just sum of
; 1,2. so returns a list of (nil 3)
(list (and (listp 3) t) (+ 1 2))