;;;# Basic Startup
(require 'package)
(require 'calendar)
(require 'uniquify)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)   ;; Added by Package.el.

;; Set variables to make emacs behave more sensibly
;; Use C-h v <variable> to get documentation on <variable>
(setq save-interprogram-paste-before-kill t
      help-window-select t
      apropos-do-all t
      mouse-yank-at-point t
      require-final-newline t
      visible-bell t
      load-prefer-newer t
      fancy-splash-image "~/.emacs.d/splash.png"
      custom-file (expand-file-name "~/.emacs.d/custom.el")
      sentence-end-double-space nil
      scroll-conservatively 100     ;Make emacs scroll sanely
      max-specpdl-size 5000
      read-quoted-char-radix 16     ;For some reason this is 8 by default
      show-paren-mode t
      ;; Numbered backups, because catastrophes happen.  The numbers
      ;; may be a bit crazy, but better safe than sorry.
      version-control t
      kept-new-versions 500
      kept-old-versions 500
      delete-old-versions t
      doc-view-continuous t
      gc-cons-threshold 32000000)

(load custom-file)  ; Normally fonts and melpa packages
(set-cursor-color "#000040")
(save-place-mode 1)            ; Return to place in file when reopening

(menu-bar-mode 1)      ; Toggle modes with arg +- 1
(column-number-mode 1)
(global-hl-line-mode 1) 

(setq-default indent-tabs-mode nil)
(setq uniquify-buffer-name-style 'forward)   ; See builtin doc for this variable
(put 'upcase-region 'disabled nil)   ; Emacs disables some things by default
(put 'narrow-to-region 'disabled nil)

(if (functionp 'global-hi-lock-mode)  ; For emacs 22 compatibility
    (global-hi-lock-mode 1)
  (hi-lock-mode 1))

;; Check if it's defined before calling since it's not builtin
(if (functionp 'bar-cursor-mode) (bar-cursor-mode)
  (message "bar-cursor-mode not present, skipping..."))
                                        

(setq default-frame-alist '((font . "Bitstream Vera Sans Mono-16")))

(add-to-list 'same-window-buffer-names "*Buffer List*")
(add-to-list 'same-window-buffer-names "*info*")

;; List of pairs for modes to launch for the given file extension.
(setq auto-mode-alist
      (append
       '(
         ("\\.m\\'" . octave-mode)
	 ("CMakeLists\\.txt\\'" . cmake-mode)
	 ("\\.cmake\\'" . cmake-mode)
         ("\\.php\\'" . web-mode) ;; Default php mode isn't as good
         ("hg-editor-.\\{6\\}\\.commit\\.hg\\.txt\\'" . diff-mode)
         ("evo[A-Z0-9]\\{6\\}\\'" . mail-mode))
       auto-mode-alist))

(add-to-list 'auto-mode-alist '("\\.el\\'" . emacs-lisp-mode))

;;;# Advanced Startup

(require 'cl-lib)       ;May as well use Common Lisp now
(setq enable-recursive-minibuffers t)

(defvar emacs-testing-dir "~/.emacs.d/testing")
(defvar emacs-unstable-dir "~/.emacs.d/unstable")

;;(cl-loop for file in (directory-files emacs-testing-dir t ".*el.?$")
;;         do (load file t))

;;(cl-loop for file in (directory-files emacs-unstable-dir t ".*el.?$")
;;         do (load file t))


(if (load "fci" t)    (fci-mode)   (message "fci mode not present, skipping..."))

;;Enable outline-mode commands for this file
(add-hook 'outline-minor-mode-hook (lambda () (setq outline-regexp ";;;\\*")))

;;Change minibuffer to toggle with mouse-1
(define-key minibuffer-inactive-mode-map [mouse-1]
  '(lambda () (interactive)
     (if (get-buffer-window "*Messages*")
	 (delete-window (get-buffer-window "*Messages*"))
       (view-echo-area-messages))))

;;Display what function you're in
(which-function-mode)

;;Disable menu toolbar and wrapping when programming
(add-hook 'find-file-hook (lambda ()
			    (when (derived-mode-p 'prog-mode)
			    (unless (eq window-system 'ns)
			      (menu-bar-mode -1))
			    (when (fboundp 'tool-bar-mode)
			      (tool-bar-mode -1))
			    (when (fboundp 'scroll-bar-mode)
			      (scroll-bar-mode -1))
			    (when (fboundp 'horizontal-scroll-bar-mode)
			      (horizontal-scroll-bar-mode -1))
                            (setq-default truncate-lines t))))

;;Swap regular and regexp search when programming
(add-hook 'find-file-hook (lambda ()
			    (when (derived-mode-p 'prog-mode)
				(global-set-key (kbd "C-s") 'isearch-forward-regexp)
				(global-set-key (kbd "C-r") 'isearch-backward-regexp)
				(global-set-key (kbd "C-M-s") 'isearch-forward)
				(global-set-key (kbd "C-M-r") 'isearch-backward))))

 ;ripgrep on windows doesn't work well
(setq dumb-jump-force-searcher 'grep)

(global-set-key (kbd "C-<return>") (lambda (arg) "Make a new line at sexp"
				     (interactive "p")
                                     (cond
                                      ((consp current-prefix-arg)
                                       (forward-list -2)
                                       (forward-list 1))
                                      ((>= 0 arg)
                                       (forward-list (1- arg))
                                       (forward-list 1))
                                      ((null arg)
                                       (forward-list 1)
                                       (insert "\n"))
                                      ((< 0 arg)
                                       (forward-list arg)))
                                     (insert "\n")
                                     (indent-for-tab-command)))

(global-set-key (kbd "C-S-<return>") (lambda (arg) "Duplicate a new sexp"
				     (interactive "p")
                                     (cond
                                      ((consp current-prefix-arg)
                                       (forward-list -2)
                                       (forward-list 1))
                                      ((>= 0 arg)
                                       (forward-list (1- arg))
                                       (forward-list 1))
                                      ((null arg)
                                       (forward-list 1)
                                       (insert "\n"))
                                      ((< 0 arg)
                                       (forward-list arg)))
                                     (mark-sexp)
                                     (kill-ring-save (region-beginning) (region-end))
                                     (yank)
                                     (forward-list 1)
                                     (forward-list -1)
                                     (indent-for-tab-command)))



;; Setup C stuff
(defun modest-arglist-indentation ()
  (c-set-offset 'arglist-close 0)
  (c-set-offset 'arglist-intro '+))
;; Highlight "FIXME: and TODO:"
;;(font-lock-add-keywords
;; 'c-mode
;; '(("\\<\\(FIXME\\)" 1 font-lock-warning-face t)))

(progn
(font-lock-add-keywords
 'c-mode
 '(("\\<\\(TODO\\):"  1
    (defface my-todo1
      '((t :foreground "blue"
	   :background "white"
	   :bold t))
      "Face for global variables." ) t)))

(font-lock-add-keywords
 'c-mode
 '(("\\<\\(TODO\\)!"  1
    (defface my-todo2
      '((t :foreground "blue"
	   :background "white"
	   :italic t
	   :bold t))
      "Face for global variables." ) t)))

(font-lock-add-keywords
 'c-mode
 '(("\\<\\(FIXME\\):"  1
    (defface my-fixme1
      '((t :foreground "red"
	   :background "white"
	   :bold t))
      "Face for global variables." ) t)))

(font-lock-add-keywords
 'c-mode
 '(("\\<\\(FIXME\\)!"  1
    (defface my-fixme2
      '((t :foreground "red"
	   :background "white"
	   :italic t
	   :bold t))
  "Face for global variables." ) t))))


(add-hook 'c-mode-hook    ;;Bring up man page for c-function with mouse
	  '(lambda ()
	     (local-set-key [M-S-mouse-1]
			    '(lambda (event) (interactive "@e")
			       (man
				(symbol-name
				 (save-excursion
				   (goto-char (posn-point (event-end event)))
				   (symbol-at-point))))))))
;; Setup Python stuff
(add-hook  'magit-mode-hook
     (lambda ()
       ;; I always run magit side-by-side to the code I'm reading
       (local-set-key (kbd "<RET>") (lambda ()
              (interactive)
              (magit-visit-item t)))))

;; Setup Elisp stuff
(add-to-list 'load-path "~/.emacs.d/ewik" t)
(add-to-list 'load-path "~/.emacs.d/lisp" t)


;;Highlight defined elisp func and var
(if (require 'hl-defined nil t)
    (progn
    ;(add-hook 'emacs-lisp-mode-hook 'hdefd-highlight-mode 'APPEND)
      (set-face-attribute 'hdefd-functions nil :foreground "orange3")
      (set-face-attribute 'hdefd-variables nil :foreground "#00a020")
      (set-face-attribute 'hdefd-undefined nil :foreground "blue3"))
  (message "failed to load hl-defined, continuing..."))



;;;# Keybindings

(global-set-key (kbd "C-S-s") 'isearch-forward-symbol-at-point)
(global-set-key (kbd "C-S-n") 'tabbar-forward-tab)
(global-set-key (kbd "C-S-p") 'tabbar-backward-tab)
(global-set-key  (kbd "C-c C-S-n") 'tabbar-forward-group)
(global-set-key  (kbd "C-c C-S-p") 'tabbar-backward-group)
(global-set-key (kbd "C-S-j") 'windmove-down)
(global-set-key (kbd "C-S-k") 'windmove-up)
(global-set-key (kbd "C-S-h") 'windmove-left)
(global-set-key (kbd "C-S-l") 'windmove-right)


;;Default behavior isn't composable with C-M-p
(global-set-key (kbd "C-M-n") (lambda ()(interactive) (forward-list 2) (forward-list -1)))


;;Enable jumping by 4 lines up/down and 4 columns left/right
(global-set-key (kbd "M-<up>") (lambda ()(interactive)
                                 (let ((start (save-excursion (move-to-window-line 0) (line-number-at-pos)))
                                       (end (save-excursion (move-to-window-line -1) (line-number-at-pos) ))
                                       (pos (line-number-at-pos)))

                                   (if (< (- pos start) 4)
                                       (move-to-window-line 0)
                                     (forward-line -4)))))

(global-set-key (kbd "M-<down>") (lambda ()(interactive)
                                 (let ((start (save-excursion (move-to-window-line 0) (line-number-at-pos)))
                                       (end (save-excursion (move-to-window-line -1) (line-number-at-pos) ))
                                       (pos (line-number-at-pos)))

                                   (if (< (- end pos) 4)
                                       (move-to-window-line -1)
                                     (forward-line 4)))))

(global-set-key (kbd "M-<left>") (lambda ()(interactive)
                                   (if (< (current-column) 4)
                                       (beginning-of-line)
                                     (forward-char -4))))

(global-set-key (kbd "M-<right>") (lambda ()(interactive)
                                   (if (< (-  (window-body-width) (current-column)) (+ 2 hscroll-margin))
                                       nil
                                     (forward-char 4))))

(global-set-key (kbd "M-S-<up>") (lambda ()(interactive) (scroll-down-line 4)))
(global-set-key (kbd "M-S-<down>") (lambda ()(interactive) (scroll-up-line 4)))
(global-set-key (kbd "M-S-<left>") (lambda ()(interactive) (scroll-right 16)))
(global-set-key (kbd "M-S-<right>") (lambda ()(interactive) (scroll-left 16)))



;Paren navigation
(global-set-key (kbd "C-S-M-i") 'backward-up-list)
(global-set-key (kbd "C-S-M-k") '(lambda (&optional arg) (interactive "P")
				   (down-list)
				   (forward-list)
				   (when arg (forward-list) (print arg))
				   (backward-list)))
(global-set-key (kbd "C-S-M-j") 'backward-list)
(global-set-key (kbd "C-S-M-l") '(lambda () (interactive)
				   (if (not (looking-at "("))
				       (skip-syntax-forward "^(")
				   (forward-list) (forward-list) (backward-list))))


;;ibuffer is great
(global-set-key (kbd "C-x C-b") 'ibuffer)

;;;# Lisp
;;;## Utility

;; Improve show-paren-mode with a second level of parens
(defface myface1    ;make ( a bit more grey
  '((((background light)) (:foreground "grey60"))
    (((background dark)) (:foreground "grey60")))
  "face for starting (")
(font-lock-add-keywords 'emacs-lisp-mode '(("[()]" 0 'myface1)))

;;TODO figure out how to make for all lisp modes?

(defface myface2    ;make ) invisible at end of a line
  '((((background light)) (:foreground "grey85"))
    (((background dark)) (:foreground "grey10")))
  "face for ending )")
(font-lock-add-keywords 'emacs-lisp-mode '(("\\b)\\()+\\)$" 1 'myface2)))

(defvar my/show-paren-timer nil "Timer to manage vertical parens")
(add-hook 'show-paren-mode-on-hook '(lambda () (interactive)
				      (setq my/show-paren-timer (run-with-idle-timer  1.0 t  #'paren-column-function))))

(add-hook 'show-paren-mode-off-hook '(lambda () (interactive)
				       (cancel-timer my/show-paren-timer)
				       (progn (delete-overlay qq0) (delete-overlay qq1))))
(if show-paren-mode (run-hooks 'show-paren-mode-on-hook))  ;show-paren-mode was enabled earlier in the file so need this here


(defvar qq0
  (let ((ol (make-overlay (point) (point) nil t))) (delete-overlay ol) ol)
  "Overlay used to highlight the paren at point.")
(defvar qq1
  (let ((ol (make-overlay (point) (point) nil t))) (delete-overlay ol) ol)
  "Overlay used to highlight the paren at point.")
(overlay-put qq0 'face 'highlight)
(overlay-put qq1 'face 'highlight)

(defvar paren-column-overlays nil)

(defun paren-column-function ()
  "Turn on highlighting for paren columns with overlays."
  (interactive)
  (let (x y (z (1+ (point))) (w (current-column)) (i 0))
    (if (or (not (looking-at "("))
)
	(progn (delete-overlay qq0)
               (delete-overlay qq1)
               (setq i 0)
               (while (< i (length paren-column-overlays))
                 (delete-overlay (nth i paren-column-overlays))
                 (setq i (1+ i)))
               (setq paren-column-overlays nil)
)
      (setq i 0)
      (progn (save-excursion    ;highlight next 2 columns
	(while (and (re-search-forward "^\\s-+(" (window-end) t)
		    (< i 2))
	  (cond ((= i 0) (and (= (current-column) (1+ w))
			      (move-overlay qq0 (1- (point)) (point))
			      (setq i (1+ i))))
		((= i 1) (and (= (current-column) (1+ w))
			      (move-overlay qq1 (1- (point)) (point))
			      (setq i (1+ i))))
		(t (error "paren-highlighting failed"))))))
      (progn (save-excursion    ;highlight sexps one level down
        (setq i 0)

        (setq y (save-excursion (forward-list 1) (point)))
        (forward-char 1)
        (condition-case nil
            (while t          ;Keep going until forward-list fails
              (forward-list 1)
              (forward-list -1)
              (setq x (make-overlay (point) (1+ (point))))
              (overlay-put x 'face 'hi-blue)
              (push x paren-column-overlays)

              (forward-list 1)
              (setq x (make-overlay (1- (point)) (point)))
              (overlay-put x 'face 'hi-blue)
              (push x paren-column-overlays)
)
          (error)))))))


