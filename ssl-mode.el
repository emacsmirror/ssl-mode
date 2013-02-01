;;; ssl-mode.el --- Emacs Major mode for S/SL files

;; Copyright (C) 2013 Nate Cybulski <nate.cybulski@gmail.com>

;; Author: Nate Cybulski <nate.cybulski@gmail.com>
;; Created: 31 Jan 2013
;; Version: 0.1
;; Keywords: S/SL
;; URL: http://github.com/npc3/ssl-mode

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; This is a language mode for the Syntax/Semantic Language, a
;; language for specifying recursive desent parsers. ssl-mode
;; provides simple syntax highlighting, commenting, and indenting.
;; Please see <http://www.zmailer.org/zman/zapp-ssl-lang.shtml>
;; for more information on S/SL.

;;; Installation:

;; place ssl-mode.el in your load-path and insert the following
;; lines into your .emacs file:
;;
;; (require 'ssl-mode)
;; (add-to-list 'auto-mode-alist '("\\.ssl\\'" . ssl-mode))

;;; Code:

(require 'font-lock)

(defvar ssl-keywords
  (regexp-opt '("input" "output" "error" "type" "mechanism" "rules" "end" "do" "if" "od" "fi"
                "Input" "Output" "Error" "Type" "Mechanism" "Rules" "End" "Do" "If" "Od" "Fi") 'words))

(defvar ssl-rule-regexp "^\\([a-zA-Z]+\\)[ \t]*\\(>>[ \t]*\\([a-zA-Z]+\\)[ \t]*\\)?:")

(defvar ssl-mode-map
  (let ((map (make-keymap)))
    map))

(defvar ssl-mode-hook nil)

(add-to-list 'auto-mode-alist '("\\.ssl\\'" . ssl-mode))

(defconst ssl-font-lock-keywords-1
  `(
    ("'.*?'" . font-lock-string-face)
    ("%.*$" . font-lock-comment-face)
    (,ssl-keywords . font-lock-keyword-face)
    (,ssl-rule-regexp (1 font-lock-function-name-face))
    ))

(defconst ssl-font-lock-keywords-2
  (append ssl-font-lock-keywords-1
          `(("@[a-zA-Z]+" . font-lock-constant-face))))

(defconst ssl-font-lock-keywords-3
  (append ssl-font-lock-keywords-2
          `(("\\*\\|\\?" . font-lock-builtin-face)
            ("#[a-zA-Z]+" . font-lock-warning-face))))

(defvar ssl-font-lock-keywords ssl-font-lock-keywords-3)

(defvar ssl-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?\" " " st)
    (modify-syntax-entry ?' "\"" st)
    (modify-syntax-entry ?% "<" st)
    (modify-syntax-entry ?\n ">" st)
    st))

(defun ssl-empty-line ()
  (looking-at "^[ \t]*$"))

(defun ssl-get-line-indent (current)
  (if (or (bobp)
          (looking-at ssl-rule-regexp))
      0
    (if (looking-at "^[ \t]*\\]")
        (progn
          (forward-line -1)
          (max 0 (- (current-indentation) tab-width)))
      (progn
        (forward-line -1)
        (cond
         ((looking-at "^[ \t]*\\({[ \t]*\\)?\\[") (+ (current-indentation) tab-width))
         ((looking-at ssl-rule-regexp) tab-width)
         (t (progn
              (while (and (ssl-empty-line) (not (bobp)))
                (forward-line -1))
              (if (looking-at ".*[^'];")
                  0
                (current-indentation)))))))))

(defun ssl-indent-line ()
  (interactive)
  (beginning-of-line)
  (let ((x))
    (save-excursion
      (setq x (ssl-get-line-indent (current-indentation))))
    (indent-line-to x)))

(defun ssl-mode ()
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table ssl-mode-syntax-table)
  (set (make-local-variable 'font-lock-defaults) '(ssl-font-lock-keywords))
  (set (make-local-variable 'indent-line-function) 'ssl-indent-line)
  (setq major-mode 'ssl-mode
        mode-name "S/SL")
  (set (make-local-variable 'comment-start) "%")
  (set (make-local-variable 'comment-end) "")
  (run-hooks 'ssl-mode-hook))

(provide 'ssl-mode)
