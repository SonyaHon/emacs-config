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
  (scroll-conservatively 10)
  (inhibit-startup-message t)
  (scroll-margin 8)
  (tab-width 4)
  (gc-cons-threshold (* 50 1000 1000))
  (read-process-output-max (* 1024 1024))
  (make-backup-files nil)
  (auto-save-default nil))

;; macos stuff
(when (eq system-type 'darwin)
  (setq mac-command-modifier 'meta))


(use-package diminish)

(use-package gruber-darker-theme)

(use-package paredit
  :diminish paredit-mode
  :hook ((emacs-lisp-mode . paredit-mode)))

;; m-x
(use-package vertico :init (vertico-mode))

(use-package marginalia :after vertico :init (marginalia-mode))

(use-package projectile :config (projectile-mode))

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
