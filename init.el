(require 'cl)

; Package archives.
(require 'package)

;--Adding archives for packages.
(add-to-list 'package-archives '("marmalade" . "https://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t) 
(package-initialize)

; Defining packages to be installed from archives.
(defvar my-packages
  '(yasnippet
    noctilux-theme
    helm
    auto-complete
        evil
	powerline
	powerline-evil
	smex
	linum-relative
	bash-completion
	which-key
	flymake-jslint
	evil-leader
	autopair)
 
  "A list of packages to ensure are installed at launch.")
 
(defun my-packages-installed-p ()
  (loop for p in my-packages
        when (not (package-installed-p p)) do (return nil)
        finally (return t)))
 
(unless (my-packages-installed-p)
  ;; check for new packages (package versions)
  (package-refresh-contents)
  ;; install the missing packages
  (dolist (p my-packages)
    (when (not (package-installed-p p))
      (package-install p))))

; Package options

;--Bash-completion
(require 'bash-completion)
(bash-completion-setup)

;--Which-key
(require 'which-key)
(which-key-mode)

;--Global Linum
(require 'linum-relative)
(linum-on)
(global-linum-mode)

;--Evil-mode
(require 'evil)
(global-evil-leader-mode)
(evil-mode 1)
;-Remapping evil-window-movement.
  (global-set-key (kbd "C-w") 'evil-window-map)
  (define-key evil-normal-state-map (kbd "C-h") 'evil-window-left)
  (define-key evil-normal-state-map (kbd "C-j") 'evil-window-down)
  (define-key evil-normal-state-map (kbd "C-k") 'evil-window-up)
  (define-key evil-normal-state-map (kbd "C-l") 'evil-window-right)
  (define-key evil-normal-state-map (kbd "C-w C-h") 'evil-window-left)
  (define-key evil-normal-state-map (kbd "C-w C-j") 'evil-window-down)
  (define-key evil-normal-state-map (kbd "C-w C-k") 'evil-window-up)
  (define-key evil-normal-state-map (kbd "C-w C-l") 'evil-window-right)

;Evil bindings.
(setq evil-leader/leader "<SPC>")
(require 'evil-leader)
(evil-leader/set-key
  "f" 'ctl-x-5-prefix
  "k" 'kill-buffer
  "SPC" 'recentf-open-files)
;--∕make sure that evil is de-activated in certain modes!(avoid fuckups!)
(loop for (mode . state) in
      '((minibuffer-inactive-mode . emacs)
        (ggtags-global-mode . emacs)
        (grep-mode . emacs)
        (Info-mode . emacs)
        (term-mode . emacs)
        (sdcv-mode . emacs)
        (anaconda-nav-mode . emacs)
        (log-edit-mode . emacs)
        (vc-log-edit-mode . emacs)
        (magit-log-edit-mode . emacs)
        (inf-ruby-mode . emacs)
        (direx:direx-mode . emacs)
        (yari-mode . emacs)
        (erc-mode . emacs)
        (neotree-mode . emacs)
        (w3m-mode . emacs)
        (gud-mode . emacs)
        (help-mode . emacs)
        (eshell-mode . emacs)
        (shell-mode . emacs)
        ;;(message-mode . emacs)
        (fundamental-mode . emacs)
        (weibo-timeline-mode . emacs)
        (weibo-post-mode . emacs)
        (sr-mode . emacs)
        (dired-mode . emacs)
        (compilation-mode . emacs)
        (speedbar-mode . emacs)
        (magit-commit-mode . normal)
        (magit-diff-mode . normal)
        (js2-error-buffer-mode . emacs)
        )
      do (evil-set-initial-state mode state))
;--Powerline(similar to VIM-powerline)
(require 'powerline)
;--Evil Mode compability for Powerline
(require 'powerline-evil)
(powerline-evil-center-color-theme)

;--jsLint
(add-hook 'js-mode-hook 'flymake-jslint-load)
				

;--Helm Config
(require 'helm)
(require 'helm-config)
(define-key helm-map (kbd "C-j") 'helm-next-line) ; Rebind
(define-key helm-map (kbd "C-k") 'helm-previous-line) ; Rebind
(helm-mode 1)

;--Enabler Window mode for better navigation.
(windmove-default-keybindings)
(setq windmove-wrap-around t)		       	

;--Yasnippets
(require 'yasnippet)
(yas-global-mode 1)

;--Auto-complete
(ac-config-default)
(global-auto-complete-mode t)

;--Auto-pair (){}[]
(require 'autopair)
(autopair-global-mode)

; Emacs config
;--Display recently used files on startup.
(require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(initial-buffer-choice (quote recentf-open-files)))

;--Display line numbers
(setq global-linum-mode t)
;--Split window on startup
(split-window-horizontally)
(set-window-buffer (next-window) (find-file "~/Org/Main.org"))

; Emacs functions

(defun my-evil-modeline-change (default-color)
  "changes the modeline color when the evil mode changes"
  (let ((color (cond ((evil-insert-state-p) '("#002233" . "#ffffff"))
                     ((evil-visual-state-p) '("#330022" . "#ffffff"))
                     ((evil-normal-state-p) default-color)
                     (t '("#440000" . "#ffffff")))))
    (set-face-background 'mode-line (car color))
    (set-face-foreground 'mode-line (cdr color))))

(lexical-let ((default-color (cons (face-background 'mode-line)
                                   (face-foreground 'mode-line))))
  (add-hook 'post-command-hook (lambda () (my-evil-modeline-change default-color))))

; Generates a new shell in current buffer.
(defun my-new-shell ()
  (interactive)

  (let (
        (currentbuf (get-buffer-window (current-buffer)))
        (newbuf     (generate-new-buffer-name "*shell*"))
       )

   (generate-new-buffer newbuf)
   (set-window-dedicated-p currentbuf nil)
   (set-window-buffer currentbuf newbuf)
   (shell newbuf)
  )
)

; Cosmetic changes
(set-frame-font "Source Code Pro-16" nil t)
(menu-bar-mode -1)
(toggle-scroll-bar -1)
(tool-bar-mode -1)

;--Themes
(load-theme 'noctilux t)

;--Keybinds
(global-set-key (kbd "M-s")'my-new-shell)
(global-set-key (kbd "M-d") 'recentf-open-more-files)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(powerline-evil-normal-face ((t (:inherit powerline-evil-base-face :background "dark green")))))
