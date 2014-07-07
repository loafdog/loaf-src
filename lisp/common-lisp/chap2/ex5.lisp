; what do these funcs do?

; (a) recursive func that chops first elem off list until it reaches
; end of list and prints nill

(defun enigma (x)
  (and (not (null x))
       (or (null (car x))
           (enigma (cdr x)))))

; prints nil
(enigma ())

; error, 1 is not list
(enigma 1)

; error 1 is not a func name, forgot ' before arg?
(enigma (1))

; prints nil
(enigma '(1))

; prints nil
(enigma '(1 2))


; (b) returns index of elem in list or nil if not in list

(defun mystery (x y)
  (if (null y)
      nil
    (if (eql (car y) x)
        0
      (let ((z (mystery x (cdr y))))
        (and z (+ z 1))))))

; wrong number args
(mystery ())

; nil
(mystery 'x '())

; 0
(mystery 'x '(x))

; 0
(mystery 'x '(x y))

; 1
(mystery 'y '(x y))

; 2
(mystery 'z '(x y z))