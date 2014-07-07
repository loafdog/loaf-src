; what could occur in place of x in each of the following

; (a) 
;> (car (x (cdr '(a (b c) d))))
;> B

; (cdr '(a (b c) d)) returns ((B C) D)
; (car (cdr '(a (b c) d))) returns (B C)
(car (car (cdr '(a (b c) d))))


; (b)
;> (x 13 (/ 1 0))
;> 13
(or 13 (/ 1 0))

; (c)
;> (x #'list 1 nil)
;(1)

; arrgggh.. can't figure it out

; stuff i tried
[64]> (list #'list 1 nil)
(#<SYSTEM-FUNCTION LIST> 1 NIL)

[65]> (if #'list 1 nil)
1

[66]> (and #'list 1 nil)
NIL

[67]> (or #'list 1 nil)                                                          
#<SYSTEM-FUNCTION LIST>

[69]> (funcall #'list 1 nil)
(1 NIL)

[70]> (lambda #'list 1 nil)
#<FUNCTION :LAMBDA #'LIST 1 NIL>

[73]> (let #'list 1 nil)
NIL
