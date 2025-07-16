;;; smart-gd.el --- VSCode-style smart goto definition for Emacs -*- lexical-binding: t; -*-

;; Copyright (C) 2025
;; Author: zhijia.zhang
;; Email: jiahut@gmail.com
;; Keywords: convenience, tools, lsp, navigation
;; Version: 0.0.1
;; Package-Requires: ((emacs "27.1") (xref "1.0"))
;; URL: https://github.com/jiahut/smart-gd.el

;;; Commentary:

;; This package brings VSCode Vim plugin's intelligent "Go to Definition" behavior to Emacs.
;;
;; Key insight: In VSCode, when you're already at a definition and press "Go to Definition",
;; it smartly switches to show references instead. This makes the workflow much more efficient.
;;
;; Behavior:
;; - When cursor is at a definition: show references
;; - When cursor is at a reference: go to definition
;;
;; This works seamlessly with LSP servers through xref, so it supports all languages
;; that have LSP support (Go, Python, JavaScript, TypeScript, Rust, C/C++, etc.)

;;; Code:

(require 'xref)

(defgroup smart-gd nil
  "VSCode-style smart goto definition for Emacs."
  :group 'navigation
  :prefix "smart-gd-")

(defcustom smart-gd-debug nil
  "Enable debug messages for smart-gd."
  :type 'boolean
  :group 'smart-gd)

(defun smart-gd--debug-message (format-string &rest args)
  "Print debug message if smart-gd-debug is enabled."
  (when smart-gd-debug
    (apply #'message format-string args)))

(defun smart-gd--at-definition-p ()
  "Check if point is at a definition using simple heuristics."
  (save-excursion
    (beginning-of-line)
    (let ((line (thing-at-point 'line t)))
      (cond
       ;; Go definitions
       ((derived-mode-p 'go-mode)
        (or (string-match-p "^\\s-*func\\s-+\\w+" line)
            (string-match-p "^\\s-*func\\s-+(\\w+\\s-+\\*?\\w+)\\s-+\\w+" line)
            (string-match-p "^\\s-*type\\s-+\\w+\\s-+\\(struct\\|interface\\)" line)
            (string-match-p "^\\s-*var\\s-+\\w+" line)
            (string-match-p "^\\s-*const\\s-+\\w+" line)))
       ;; Python definitions
       ((derived-mode-p 'python-mode)
        (string-match-p "^\\s-*\\(def\\|class\\|async\\s-+def\\)\\s-+" line))
       ;; JavaScript/TypeScript definitions
       ((or (derived-mode-p 'js-mode)
            (derived-mode-p 'typescript-mode)
            (derived-mode-p 'js2-mode))
        (or (string-match-p "^\\s-*function\\s-+\\w+" line)
            (string-match-p "^\\s-*\\(const\\|let\\|var\\)\\s-+\\w+\\s-*=\\s-*function" line)
            (string-match-p "^\\s-*\\(const\\|let\\|var\\)\\s-+\\w+\\s-*=\\s-*(" line)
            (string-match-p "^\\s-*class\\s-+\\w+" line)
            (string-match-p "^\\s-*interface\\s-+\\w+" line)
            (string-match-p "^\\s-*type\\s-+\\w+" line)))
       ;; C/C++ function definitions
       ((or (derived-mode-p 'c-mode)
            (derived-mode-p 'c++-mode))
        (and (string-match-p "\\w+\\s-*(" line)
             (not (string-match-p ";\\s-*$" line))
             (save-excursion
               (end-of-line)
               (re-search-forward "{" (line-end-position 3) t))))
       ;; Rust definitions
       ((derived-mode-p 'rust-mode)
        (or (string-match-p "^\\s-*\\(pub\\s-+\\)?fn\\s-+\\w+" line)
            (string-match-p "^\\s-*\\(pub\\s-+\\)?struct\\s-+\\w+" line)
            (string-match-p "^\\s-*\\(pub\\s-+\\)?enum\\s-+\\w+" line)
            (string-match-p "^\\s-*\\(pub\\s-+\\)?trait\\s-+\\w+" line)))
       ;; Elisp definitions
       ((derived-mode-p 'emacs-lisp-mode)
        (or (string-match-p "^\\s-*(defun\\s-+\\w+" line)
            (string-match-p "^\\s-*(defmacro\\s-+\\w+" line)
            (string-match-p "^\\s-*(defvar\\s-+\\w+" line)
            (string-match-p "^\\s-*(defcustom\\s-+\\w+" line)))
       ;; Default: not at definition
       (t nil)))))

;;;###autoload
(defun smart-gd-goto-definition-or-references ()
  "Smart navigation: goto definition or show references based on context.
If point is at a definition, show references. Otherwise, go to definition.
Uses xref functions which are already mapped by eglot."
  (interactive)
  (if (smart-gd--at-definition-p)
      (progn
        (smart-gd--debug-message "At definition, showing references...")
        (call-interactively 'xref-find-references))
    (progn
      (smart-gd--debug-message "Going to definition...")
      (call-interactively 'xref-find-definitions))))

(defun smart-gd--xref-find-definitions-advice (orig-fun &rest args)
  "Advice for xref-find-definitions to add smart behavior."
  (if (smart-gd--at-definition-p)
      (progn
        (smart-gd--debug-message "At definition, showing references...")
        (call-interactively 'xref-find-references))
    (progn
      (smart-gd--debug-message "Going to definition...")
      (apply orig-fun args))))

;;;###autoload
(defun smart-gd-setup ()
  "Setup smart-gd by replacing xref-find-definitions with smart behavior."
  (interactive)
  (advice-add 'xref-find-definitions :around #'smart-gd--xref-find-definitions-advice)
  (message "Smart-gd: xref-find-definitions enhanced with smart behavior"))

;;;###autoload
(defun smart-gd-disable ()
  "Disable smart-gd by removing the advice."
  (interactive)
  (advice-remove 'xref-find-definitions #'smart-gd--xref-find-definitions-advice)
  (message "Smart-gd: disabled"))

(provide 'smart-gd)

;;; smart-gd.el ends here
