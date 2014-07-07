
; Using car and cdr define a func to return the 3th elem of a list

; car is first element of list. cdr drops first elem of list and
; returns rest. So use cdr 3x to drop first 3 elems and then car to
; get first elem

(defun our-fourth (x) (car (cdr (cdr (cdr x)))))

(our-fourth '(a b c d e))