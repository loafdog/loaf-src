
; define a func that takes two args and returns greater of two

(defun greater (x y)
  (if (> x y)
      x
    y
    )
)

(greater 1 2)

(greater 3 2)

(greater 2 2)