; Using only operators introduced in this chapter define a function
; that takes a list as an argument and returns true if one of its
; elements is a list

(defun has_list_recursive (lst)
  (if (null lst)
      nil
    (if (listp (car lst))
        t
      (has_list_recursive (cdr lst))))
)

(has_list_recursive '(a b c))
(has_list_recursive '(a (b c)))
(has_list_recursive '(a b (c)))
(has_list_recursive '(a (b) c))
(has_list_recursive '((a) b c))


(defun has_list_iterative (lst)
  (if (null lst)
      nil
    lst
    ))

(defun has_list_iterative (lst)
  (if (null lst)
      nil
    (dolist (obj lst)
      (if (listp obj)
          (setf islist t)
        ))
    islist))

(has_list_iterative '(a b c))
(has_list_iterative '(a (b c)))
(has_list_iterative '(a b (c)))
(has_list_iterative '(a (b) c))
(has_list_iterative '((a) b c))
