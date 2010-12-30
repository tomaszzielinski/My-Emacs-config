;; Autor: Tomasz Zieliński
;; General guidelines for Emacs+Python: http://www.emacswiki.org/emacs/PythonMode

;; http://xahlee.org/emacs/emacs_make_modern.html

(tool-bar-mode -1) ;; remove toolbar - it's only wasting screen space

(add-to-list 'load-path "~/.emacs.d/")

;; Python.el config (from: http://www.loveshack.ukfsn.org/emacs/python.el) - !!note that Emacs22/23's default python.el has to be removed!!
;;(require 'python)
;; ^^^ I RENAMED THAT python.el TO python-old.el, AS Emacs 23.3 should have a newer, nicer version of it bundled with itself  

; Those settings are not needed in with a working python.el, but having them here DO help with some .py files
; that otherwise use 8-chat *tabs*
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default py-indent-offset 4)  ;; allegedly python-mode.el but let's try 
(setq sgml-basic-offset 4)  ;; indentation for html (http://stackoverflow.com/questions/2076783/cant-change-emacss-default-indentation-between-html-tags/2077471#2077471)

;; Pymacs and Ropemacs
(require 'pymacs)
(pymacs-load "ropemacs" "rope-")

;; Autocomplete.el
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d//ac-dict")
(ac-config-default)

;; Disable annoying system beeps 
(setq visible-bell t)

;; Normal Copy&Paste and so called CUA
(cua-mode t)
(setq cua-auto-tabify-rectangles nil) ;; Don't tabify after rectangle commands
(transient-mark-mode 1)               ;; No region when it is not highlighted
(delete-selection-mode 1)             ;; delete seleted text when typing
(setq cua-keep-region-after-copy t)   ;; Standard Windows behaviour

;; Column&line numbers
(column-number-mode 1)
(line-number-mode 1)                  ;; show current line no.
(require 'linum)
(global-linum-mode)   ;; show line numbers for all lines

;; Enhanced VS-like bookmarks
(require 'bm)
(global-set-key (kbd "<C-f2>") 'bm-toggle)
(global-set-key (kbd "<f2>")   'bm-next)
(global-set-key (kbd "<S-f2>") 'bm-previous)

;; Tabs near the top of windows
(require 'tabbar)
(tabbar-mode)

;; Misc
(show-paren-mode 1)                   ;; Highlight matching braces
(add-hook 'text-mode-hook (lambda () (hl-line-mode 1))) ;; highlight current line

(recentf-mode 1)  ;; add File submenu with recently opened files
(global-set-key "\C-x\ \C-r" 'recentf-open-files)  ;; Bind C-x C-r to it

(setq x-select-enable-clipboard t)   ;; Make Copy use system clipboard

(setq default-truncate-lines t) ;; disable line wrap
(setq truncate-partial-width-windows nil) ;; make side by side buffers function the same as the main window

;; (desktop-save-mode 1) ;; save session - http://www.emacswiki.org/emacs/DeskTop   <<<<< Opening files is so SLOOOOW that it's much better to open needed ones manually
;; (setq history-length 250)  ;; remember more than 10 last files

(require 'whitespace) ;; show spaces, tabs, newlines (present in Emacs 23 std scripts)
(global-whitespace-mode 1) ;; activate whitespace display (http://www.emacswiki.org/emacs/WhiteSpace)
(setq whitespace-style (quote
  ( spaces tabs newline space-mark tab-mark newline-mark)))  ;; remove all the bells&whistles, leaving only useful stuff (http://xahlee.org/emacs/whitespace-mode.html)
(setq whitespace-display-mappings
 '(
   (space-mark 32 [183] [46]) ; normal space
   (space-mark 160 [164] [95])
   (space-mark 2208 [2212] [95])
   (space-mark 2336 [2340] [95])
   (space-mark 3616 [3620] [95])
   (space-mark 3872 [3876] [95])
   (newline-mark 10 [182 10]) ; newlne
   (tab-mark 9 [9655 9] [92 9]) ; tab
)) ;; Modify EOL char from $ to ¶ and some other chars to more verbose ones (http://xahlee.org/emacs/whitespace-mode.html)

(require 'autopair) ;; Automatically closes brackets
(autopair-global-mode) ;; to enable in all buffers

(require 'uniquify)  ;; to make buffer names unique when two files have the same name (eg models.py) - uniquify is distibuted along with emacs
(setq uniquify-buffer-name-style 'forward)  ;; see `less /usr/share/emacs/22.2/lisp/uniquify.elc` for all options available

;; Smart HOME key behaviour
;; TZ: Taken from here: http://stackoverflow.com/questions/145291/smart-home-in-emacs/145360#145360 (Author: Robert Vuković)
(defun My-smart-home () "Odd home to beginning of line, even home to beginning of text/code."
    (interactive)
    (if (and (eq last-command 'My-smart-home)
                (/= (line-beginning-position) (point)))
    (beginning-of-line)
    (beginning-of-line-text))
)
(global-set-key [home] 'My-smart-home)


;; YaSnippets snippets
(require 'yasnippet-bundle)
(yas/initialize)
(yas/load-directory "~/.emacs.d/yasnippets")


;; Auto-Higlight code problems using Flymake+PyFlakes
;; http://hide1713.wordpress.com/2009/01/30/setup-perfect-python-environment-in-emacs/
;; http://www.plope.com/Members/chrism/flymake-mode
;; http://www.emacswiki.org/emacs/PythonMode
(require 'flymake)

; From http://stackoverflow.com/questions/1259873/how-can-i-use-emacs-flymake-mode-for-python-with-pyflakes-and-pylint-checking-cod/1393590#1393590 (author: vaab)
(when (load "flymake" t)
  (defun flymake-pyflakes-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
               'flymake-create-temp-inplace))
       (local-file (file-relative-name
            temp-file
            (file-name-directory buffer-file-name))))
      (list "pycheckall" (list local-file))))
  (add-to-list 'flymake-allowed-file-name-masks
           '("\\.py\\'" flymake-pyflakes-init)))
(add-hook 'find-file-hook 'flymake-find-file-hook)

;; Bind closing all buffers to C-c x
(defun close-all-buffers ()
  (interactive)
  (mapc 'kill-buffer (buffer-list)))
(global-set-key "\C-cx" 'close-all-buffers)
