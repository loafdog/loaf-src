;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This is 80 chars wide                                                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; not sure why this isn't included by default..
(add-to-list 'load-path "~/.emacs.d/")

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(delete-key-deletes-forward t)
 '(desktop-save-mode 1)
 '(highlight-tabs t)
 '(highlight-trailing-whitespace t)
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(iswitchb-mode 1)
 '(menu-bar-mode 0)
 '(mouse-yank-at-point t)
 '(put (quote downcase-region) t)
;; '(save-place 1 nil (saveplace))
 '(scroll-bar-mode nil)
 '(sh-alias-alist (quote ((csh . tcsh) (ksh . pdksh) (ksh . ksh88) (bash2 . bash) (sh5 . sh) (sh . bash))))
 '(show-paren-mode 1)
 '(tool-bar-mode nil)
 '(visible-bell t))

(setq-default c-basic-offset 4)
(setq c-default-style "linux"
      c-basic-offset 4)

(put 'narrow-to-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;; make scrolling happen one line at a time instead of jumping
;; screens. not sure what the scroll-step and scroll-conservatively
;; settings do.. found thread online that suggested all 3 but only
;; need vscroll
                                        ;(setq scroll-step 1)
                                        ;(setq scroll-conservatively 10000)
(setq auto-window-vscroll nil)

;; prevent *Minibuf-1* from appearing in iswitchb list first all the
;; time
(setq iswitchb-buffer-ignore '("^ "))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sudo apt-get install cscope-el
;;http://linux.die.net/man/1/xcscope
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'xcscope)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GIT stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(add-to-list 'load-path "/data/emacs/magit")
(add-to-list 'load-path "/data/emacs/magit/contrib")
(require 'magit)
;; change magit diff colors
(eval-after-load 'magit
  '(progn
     (set-face-foreground 'magit-diff-add "green3")
     (set-face-foreground 'magit-diff-del "red3")
     (when (not window-system)
       (set-face-background 'magit-item-highlight "black"))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; fix indentation, white-space, and tabs in entire file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
(defun iwb ()
  "indent whole buffer"
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; tramp setup
;;
;; To edit the target file, hit Cntl-x followed by Cntl-f, and enter
;; the following before hitting return:
;;
;; Edit a file as root on local system
;; /su::/etc/hosts.allow
;;
;; Edit a file on remote system
;; /remotehost:filename RET (or /method:user@remotehost:filename)
;; /root@10.152.8.156:/genesis/initialize
;;
(require 'tramp)
(setq tramp-default-method "scp")

;; disable backups when using su/sudo to edit files
(setq backup-enable-predicate
      (lambda (name)
        (and (normal-backup-enable-predicate name)
             (not
              (let ((method (file-remote-p name 'method)))
                (when (stringp method)
                  (member method '("su" "sudo"))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; save desktop at regular intervals
;;
(defun my-desktop-save ()
  (interactive)
  ;; `desktop-owner' is a new function in Emacs 22.1.50 to check
  ;; for conflicts between two running Emacs instances.
  ;; We don't want automatic saving in the second Emacs process.
  (if (and (fboundp 'desktop-owner) (eq (desktop-owner) (emacs-pid)))
      (desktop-save "~")))

;; Save the desktop every minute
(run-at-time 60 600 'my-desktop-save)
;; Save the desktop every hour
;;(run-at-time 3600 3600 'my-desktop-save)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Change auto-save dir to system temp dir
;;
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Remember position in a file/buffer
;;
;; keep my ~/ clean
;(setq save-place-file "~/.emacs.d/saveplace")
;; activate it for all buffers
;(setq-default save-place t)
;; (setq-default save-place nil)
;; get the package
;(require 'saveplace)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enable cua-mode. 
;;
;; http://www.gnu.org/software/emacs/manual/html_node/emacs/CUA-Bindings.html#CUA-Bindings
;; http://www.emacswiki.org/emacs/CuaMode
;;
;; This enables keys like C-v, C-c, C-x to paste,copy,cut. I turned
;; that off. do not want. I use this for working with rectangle
;; regions.  Use C-Ret to start marking rectangle.
;;
;; Also use global mark. When gmark is set all text copy/killed or
;; typed is inserted at global mark. Set gmark with C-S-SPC.

;; None of these things work to turn on cua-mode. When reloading .emacs
;; file emacs says cua mode is disabled?  I can't find a way to make 
;; the msg disappear.
;; Need to turn it on manually using M-x cua-mode.
;;(setq cua-mode t)
;;(cua-mode t)
;;(setq-default cua-mode t)
;;(cua-mode)

;; Don't tabify after rectangle commands
(setq cua-auto-tabify-rectangles nil)

;; No region when it is not highlighted
(transient-mark-mode 1)

;; Standard Windows behaviour
(setq cua-keep-region-after-copy t)

;; Keep standard emacs keys when using cua mode
(cua-selection-mode nil)
;; doesn't work.. sym/func doesn't exist
;;(cua-enable-cua-keys nil)

;; after copying text disable mark/selection. Matches default non-cua
;; mode emacs behavior
(setq cua-keep-region-after-copy nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Color settings
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Original color settings
;;
;;(custom-set-faces
;; custom-set-faces was added by Custom.
;; If you edit it by hand, you could mess it up, so be careful.
;; Your init file should contain only one such instance.
;; If there is more than one, they won't work right.
;; '(default ((t (:inherit nil :stipple nil :background "white" :foreground "black" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 98 :width normal :foundry "unknown" :family "DejaVu Sans Mono")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 2 ways - you can install the package color-theme, which has lots
;; of nice schemes to select and is easier to do it by hand.
;; sudo apt-get install emacs-goodies-el
;; and then enable this stuff:
;;
                                        ;(add-to-list 'load-path "/usr/share/emacs/site-lisp/emacs-goodies-el/color-theme.el")
                                        ;(setq load-path (cons "/usr/share/emacs/site-lisp/emacs-goodies-el/color-theme.el" load-path))
                                        ;(require 'color-theme)
                                        ;(eval-after-load "color-theme"
                                        ;  '(progn
                                        ;     (color-theme-initialize)
                                        ;     (color-theme-hober)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Or setup color manually. You can also type
;; `M-x customize-face RET`
;; which will give you all the customizations to set, ultimately end
;; up in your .emacs.

(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "black" :foreground "red" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight bold :width normal :family "liberation mono"))))
 '(background "blue")
 '(font-lock-builtin-face ((((class color) (background dark)) (:foreground "Turquoise"))))
 '(font-lock-comment-face ((t (:foreground "yellow"))))
 '(font-lock-constant-face ((((class color) (background dark)) (:bold t :foreground "DarkOrchid"))))
 '(font-lock-doc-string-face ((t (:foreground "green2"))))
 '(font-lock-function-name-face ((t (:foreground "SkyBlue"))))
 '(font-lock-keyword-face ((t (:bold t :foreground "CornflowerBlue"))))
 '(font-lock-preprocessor-face ((t (:italic nil :foreground "CornFlowerBlue"))))
 '(font-lock-reference-face ((t (:foreground "DodgerBlue"))))
 '(font-lock-string-face ((t (:foreground "LimeGreen"))))
 '(magit-item-highlight ((t nil))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ansi term customizatino

;; close ansi term window after u exit
(defadvice term-sentinel (around my-advice-term-sentinel (proc msg))
  (if (memq (process-status proc) '(signal exit))
      (let ((buffer (process-buffer proc)))
        ad-do-it
        (kill-buffer buffer))
    ad-do-it))
(ad-activate 'term-sentinel)

;; Use bash by default. Gets rid of ansi term prompt which program to run
(defvar my-term-shell "/bin/bash")
(defadvice ansi-term (before force-bash)
  (interactive (list my-term-shell)))
(ad-activate 'ansi-term)

;; C-y doesn't work in ansi-term like you'd expect. It pastes into the
;; buffer, sure, but the text doesn't get sent to the process. So if
;; you copy a bash command, then C-y it into the buffer, nothing
;; happens when you press enter (because, as far as ansi-term is
;; concerned, no text was entered at the prompt). The following
;; function will paste whatever is copied into ansi-term in such a way
;; that the process can, well, process it
(defun my-term-paste (&optional string)
  (interactive)
  (process-send-string
   (get-buffer-process (current-buffer))
   (if string string (current-kill 0))))

;; my custom hook func for ansi-term
(defun my-term-hook ()
  (goto-address-mode)
  (define-key term-raw-map "\C-y" 'my-term-paste)
  (let ((base03  "#002b36")
        (base02  "#073642")
        (base01  "#586e75")
        (base00  "#657b83")
        (base0   "#839496")
        (base1   "#93a1a1")
        (base2   "#eee8d5")
        (base3   "#fdf6e3")
        (yellow  "#b58900")
        (orange  "#cb4b16")
        (red     "#dc322f")
        (magenta "#d33682")
        (violet  "#6c71c4")
        (blue    "#268bd2")
        (cyan    "#2aa198")
        (green   "#859900"))
    (setq ansi-term-color-vector
          (vconcat `(unspecified ,base02 ,red ,green ,yellow ,blue
                                 ,magenta ,cyan ,base2))))
  )

(add-hook 'term-mode-hook 'my-term-hook)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; multi-term setup
;;
;; (require 'multi-term)
;; (setq multi-term-program "/bin/bash")
;; (setq multi-term-scroll-show-maximum-output t)
;; (setq multi-term-scroll-to-bottom-on-output t)
;; (load "multi-term-settings.el")

                                        ;(setq term-unbind-key-list '("<ESC>"))

;; bugs in multi-term.el prevent you from re-mapping/escaping keys
;; this is for ctrl-c
                                        ;(define-key term-raw-map [?\C-c] 'term-send-raw)


;; (defun term-send-esc ()
;;   "Send ESC in term mode."
;;   (interactive)
;;   (term-send-raw-string "\e"))

;; (setq
;;  term-bind-key-alist
;;  `(
;;    ("<ESC>-1"   . term-send-esc)
;;    ("<f5>"   . term-send-esc)
;; ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Experiment with cedet stuff

;; start speedbar if we're using a window system
                                        ;(when window-system (speedbar t))

;; start speedbar all the time
                                        ;(speedbar 1)

;; Tell emacs where gtags.el is if its not in standard place like
;; /usr/share/emacs/site-lisp/global
                                        ;(setq load-path (cons "/path/to/gtags.el" load-path))
                                        ;(setq load-path (cons "/usr/share/emacs/site-lisp/global/gtags.el" load-path))
;; Load gtags
                                        ;(autoload 'gtags-mode "gtags" "" t)

;; If you would like Emacs to go into gtags mode whenever you enter c
;; mode, add the following section. If instead you would rather
;; control when gtags mode starts, omit this section and turn on gtags
;; mode when you want it, via M-x gtags-mode
;; (add-hook 'c-mode-hook
;;    '(lambda ()
;;       (gtags-mode t)
;;    '(add-to-list 'completion-at-point-functions 'semantic-completion-at-point-function)
;; ))

;; if semantic is not enabled by default, you can add it the following
;; line to your major mode hook of choice:
                                        ;(add-to-list 'completion-at-point-functions 'semantic-completion-at-point-function)
