;; emacs configuration

;; startup benchnarking
(defun start/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time (time-subtract after-init-time before-init-time)))
           gcs-done))
(add-hook 'emacs-startup-hook #'start/display-startup-time)

;; use package ensure
(require 'use-package-ensure) 
(setq use-package-always-ensure t)
(setq package-archives '(("melpa" . "https://melpa.org/packages/") ;; Sets default package repositories
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/"))) ;; For Eat Terminal

;;;;;;;;;;;;;;;;;;;;; PACKAGES ;;;;;;;;;;;;;;;;;;;;;
;; sane defaults
(use-package emacs
  :custom
  (menu-bar-mode nil)
  (scroll-bar-mode nil)
  (tool-bar-mode nil)
  (global-auto-revert-mode)
  (display-line-numbers-type 'relative)
  (global-display-line-numbers-mode t)
  (mouse-wheel-progressive-speed nil)
  (tab-always-indent t)
  (scroll-conservatively 10)
  (inhibit-startup-message t)
  (scroll-margin 8)
  (tab-width 4)
  (gc-cons-threshold (* 50 1000 1000))
  (read-process-output-max (* 1024 1024))
  (make-backup-files nil)
  (Man-sed-command "gsed")
  (use-short-answers t)
  (auto-save-default nil)
  
  :init
  (savehist-mode))

;; macos stuff
(when (eq system-type 'darwin)
  (setq mac-command-modifier 'meta))


(use-package diminish)

(use-package gruber-darker-theme)

(use-package paredit
  :diminish paredit-mode
  :hook ((emacs-lisp-mode . paredit-mode)))

;; m-x
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles basic partial-completion)))))
(use-package vertico :init (vertico-mode))

(use-package marginalia :after vertico :init (marginalia-mode))

(use-package ripgrep)
(use-package projectile
  :config (projectile-mode)
  :bind
  (("C-x p f" . projectile-find-file)
   ("C-x p c" . projectile-compile-project)
   ("C-x p g" . projectile-ripgrep)))

(use-package helpful
  :bind
  ("C-h f" . helpful-callable)
  ("C-h v" . helpful-variable)
  ("C-h k" . helpful-key)
  ("C-h x" . helpful-command))

;; utilities
(use-package phi-search
  :bind
  ("C-s" . phi-search)
  ("C-r" . phi-search-backward))

(use-package multiple-cursors
  :bind
  ("C-c C-n" . mc/mark-next-like-this-symbol)
  ("C-c C-p" . mc/unmark-next-like-this)
  ("C-c C-." . mc/skip-to-next-like-this)
  ("C-c C-l" . mc/edit-ends-of-lines))

(use-package crux
  :bind (("C-k" . crux-smart-kill-line)))

(use-package corfu
  :diminish cnnorfu-mode
  :custom
  (corfu-cycle t)
  :bind
  ("C-." . completion-at-point)
  (:map corfu-map
		("TAB" . nil)
		("S-TAB" . nil)
		([tab] . nil)
		([backtab] . nil)
		("RET" . nil)
		("C-n" . corfu-next)
		("C-p" . corfu-previous)
		("C-y" . corfu-insert))
  :init
  (global-corfu-mode))

(use-package cape
  :after corfu
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-abbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block)
  (add-hook 'completion-at-point-functions #'cape-keyword))

(use-package eat
  :hook ('eshell-load-hook #'eat-eshell-mode))

;; lsp
(use-package eglot
  :ensure nil
  :config
  (add-to-list 'eglot-server-programs
			   `(typescript-ts-mode . ("/Users/sonyahon/.emacs.d/node_modules/.bin/typescript-language-server" "--stdio"))))

;; Compilation mode
;; Stolen from (http://endlessparentheses.com/ansi-colors-in-the-compilation-buffer-output.html)
(require 'ansi-color)
(defun endless/colorize-compilation ()
  "Colorize from `compilation-filter-start' to `point'."
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region
     compilation-filter-start (point))))

(add-hook 'compilation-filter-hook
          #'endless/colorize-compilation)

;; Stolen from (https://oleksandrmanzyuk.wordpress.com/2011/11/05/better-emacs-shell-part-i/)
(defun regexp-alternatives (regexps)
  "Return the alternation of a list of regexps."
  (mapconcat (lambda (regexp)
               (concat "\\(?:" regexp "\\)"))
             regexps "\\|"))

(defvar non-sgr-control-sequence-regexp nil
  "Regexp that matches non-SGR control sequences.")

(setq non-sgr-control-sequence-regexp
      (regexp-alternatives
       '(;; icon name escape sequences
         "\033\\][0-2];.*?\007"
         ;; non-SGR CSI escape sequences
         "\033\\[\\??[0-9;]*[^0-9;m]"
         ;; noop
         "\012\033\\[2K\033\\[1F"
         )))

(defun filter-non-sgr-control-sequences-in-region (begin end)
  (save-excursion
    (goto-char begin)
    (while (re-search-forward
            non-sgr-control-sequence-regexp end t)
      (replace-match ""))))

(defun filter-non-sgr-control-sequences-in-output (ignored)
  (let ((start-marker
         (or comint-last-output-start
             (point-min-marker)))
        (end-marker
         (process-mark
          (get-buffer-process (current-buffer)))))
    (filter-non-sgr-control-sequences-in-region
     start-marker
     end-marker)))

(add-hook 'comint-output-filter-functions
          'filter-non-sgr-control-sequences-in-output)

;; COMPILATION ERROR REGEXes
(add-to-list 'compilation-error-regexp-alist
			 '("at \\(.*?\\):\\([0-9]+\\):\\([0-9]+\\)" 1 2 3))
(add-to-list 'compilation-error-regexp-alist
			 '("at main (\\(.*?\\):\\([0-9]+\\):\\([0-9]+\\))" 1 2 3))
(add-to-list 'compilation-error-regexp-alist
			 '("^\\(.*?\\):\\([0-9]+\\):\\([0-9]+\\):" 1 2 3))

;; Language: Typescript/Tsx
(add-to-list 'auto-mode-alist
			 '("\\.tsx?\\'" . typescript-ts-mode))


;; Language: Zig
(use-package zig-mode
  :custom
  (zig-format-on-save nil)
  (zig-ast-check-on-format nil))

;;;;;;;;;;;;;;;;;;;;; CUSTOM_FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;
(defun load-styles ()
  (load-theme 'gruber-darker t)
  (set-face-attribute 'default nil
                      :font "Iosevka Nerd Font"
                      :height 120)
  (setq-default line-spacing 0.12))

;;;;;;;;;;;;;;;;;;;;;; AUTO_GENERATED ;;;;;;;;;;;;;;;;;;;;;;
(load-styles)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("01a9797244146bbae39b18ef37e6f2ca5bebded90d9fe3a2f342a9e863aaa4fd"
	 default))
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
