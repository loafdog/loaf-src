
; three different cons expressions to make a list (A B C)

; 1
(cons 'a '(b c))

; 2
(cons 'a (cons 'b (cons 'c nil)))

; 3 .. can't find 3rd way to do it... unless you count change nil to
; () as a 3rd way.
(cons 'a (cons 'b (cons 'c ())))

; not quite
(cons '(a b) '(c))
(cons '(a b) 'c)
(cons 'b (cons 'a ()))

; no work, error/syntax
(cons (a b) 'c)