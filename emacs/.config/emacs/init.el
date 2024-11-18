;; NOTE: init.el is now generated from Emacs.org.  Please edit that file
;;       in Emacs and init.el will be generated automatically!

;; You will most likely need to adjust this font size for your system!
(defvar efs/default-font-size 180)
(defvar efs/default-variable-font-size 180)

;; Make frame transparency overridable
(defvar efs/frame-transparency '(90 . 90))

;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

(defun efs/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                     (time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'efs/display-startup-time)

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

  ;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe)
  (auto-package-update-at-time "09:00"))

;; NOTE: If you want to move everything out of the ~/.emacs.d folder
;; reliably, set `user-emacs-directory` before loading no-littering!
;(setq user-emacs-directory "~/.cache/emacs")

(use-package no-littering)

;; no-littering doesn't set this by default so we must place
;; auto save files in the same path as it uses for sessions
(setq auto-save-file-name-transforms
      `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar

;; Set up the visible bell
(setq visible-bell t)

(column-number-mode)
(global-display-line-numbers-mode t)

;; Set frame transparency
(set-frame-parameter (selected-frame) 'alpha efs/frame-transparency)
(add-to-list 'default-frame-alist `(alpha . ,efs/frame-transparency))
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                treemacs-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(use-package general
  :after evil
  :config
  (general-create-definer efs/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (efs/leader-keys
    "t"  '(:ignore t :which-key "toggles")
    "tt" '(counsel-load-theme :which-key "choose theme")
    "b" '(:ignore b :which-key "buffers")
    "bb" 'counsel-switch-buffer
    "f" '(:ignore f :which-key "files")
    "ff" 'find-file
    "fde" '(lambda () (interactive) (find-file (expand-file-name "~/.config/emacs/emacs.org")))
    "g" '(:ignore g :which-key "git")
    "gs" 'magit-status
    "o" '(:ignore o :which-key "orgmode")
    "obt" 'org-babel-tangle
    "oc" 'org-capture
    "os" 'org-schedule
    "oa" 'org-agenda
    ))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (evil-set-undo-system 'undo-tree)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package undo-tree
  :ensure t
  :init (global-undo-tree-mode))

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 1))

(use-package ivy
    :diminish
    :bind (("C-s" . swiper)
           :map ivy-minibuffer-map
           ("TAB" . ivy-alt-done)
           ("C-l" . ivy-alt-done)
           ("C-j" . ivy-next-line)
           ("C-k" . ivy-previous-line)
           :map ivy-switch-buffer-map
           ("C-k" . ivy-previous-line)
           ("C-l" . ivy-done)
           ("C-d" . ivy-switch-buffer-kill)
           :map ivy-reverse-i-search-map
           ("C-k" . ivy-previous-line)
           ("C-d" . ivy-reverse-i-search-kill))
    :config
    (ivy-mode 1))

  (use-package ivy-rich
    :after ivy
    :init
    (ivy-rich-mode 1))
(use-package ivy-posframe
  :ensure t
  :after ivy
  :config
  ;; Display Ivy completions in a posframe
  (setq ivy-posframe-display-functions-alist
        '((t . ivy-posframe-display)))

  ;; Optional: Customize posframe appearance
  (setq ivy-posframe-parameters '((left . 10)  ;; Horizontal position
                                  (top . 10)   ;; Vertical position
                                  (width . 40) ;; Width of the frame
                                  (height . 10) ;; Height of the frame
                                  (internal-border-width . 10))) ;; Border width
  
  ;; Make Ivy use posframe for display
  (ivy-posframe-mode 1))

(use-package counsel
  :ensure t
  :bind (("C-s" . counsel-grep-or-swiper)  ;; Use swiper for search
         ("M-x" . counsel-M-x)           ;; Use Counsel M-x
         ("C-x C-f" . counsel-find-file))) ;; Use Counsel find file

(use-package ivy-prescient
  :after counsel
  :custom
  (ivy-prescient-enable-filtering nil)
  :config
  ;; Uncomment the following line to have sorting remembered across sessions!
  ;(prescient-persist-mode 1)
  (ivy-prescient-mode 1))

(use-package nerd-icons
:ensure t
)
(use-package doom-modeline
:ensure t
:init (doom-modeline-mode 1))

(use-package dashboard
      :ensure t
      :config
      (dashboard-setup-startup-hook))
  (setq dashboard-items '((recents   . 5)
                          (bookmarks . 5)
                          (projects  . 5)
                          (agenda    . 5)
                          (registers . 5)))
  (setq dashboard-display-icons-p t)     ; display icons on both GUI and terminal
(setq dashboard-icon-type 'nerd-icons) ; use `nerd-icons' package

(use-package eglot
    :ensure t
      :hook ((prog-mode . eglot-ensure))
    :config
    (setq eglot-server-programs
	  '((python-mode . ("pyright"))
	    (js-mode . ("typescript-language-server" "--stdio"))
	    ;; Add more language servers here as needed
	    )))
  (use-package company
    :ensure t
    :hook (prog-mode . company-mode)  ;; Enable company mode in programming modes
:bind (:map company-active-map
	   ("<tab>" . company-complete-selection))
    :custom
    (company-minimum-prefix-length 1)
    (company-idle-delay 0.0)
    :config
    (setq company-idle-delay 0.2    ;; Delay before completion menu pops up
	  company-minimum-prefix-length 1  ;; Trigger completions after 1 char
	  company-selection-wrap-around t  ;; Wrap around completion list
	  company-tooltip-limit 20))  ;; Max number of suggestions in tooltip

  (global-company-mode 1)

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/Projects/Code")
    (setq projectile-project-search-path '("~/Projects/Code")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :after projectile
  :config (counsel-projectile-mode))

(use-package magit
  :commands magit-status
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; NOTE: Make sure to configure a GitHub token before using this package!
;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started
(use-package forge
  :after magit)

(use-package evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; When a TODO is set to a done state, record a timestamp
(setq org-log-done 'time)

;; Follow the links
(setq org-return-follows-link  t)

;; Associate all org files with org mode
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(setq org-agenda-files '("~/org"))
;; Make the indentation look nicer
(add-hook 'org-mode-hook 'org-indent-mode)
;; Hide the markers so you just see bold text as BOLD-TEXT and not *BOLD-TEXT*
(setq org-hide-emphasis-markers t)

;; Wrap the lines in org mode so that things are easier to read
(add-hook 'org-mode-hook 'visual-line-mode)

;; TODO colors
(setq org-todo-keywords
      '((sequence "TODO(t)" "PLANNING(p)" "IN-PROGRESS(i@/!)" "VERIFYING(v!)" "BLOCKED(b@)"  "|" "DONE(d!)" "OBE(o@!)" "WONT-DO(w@/!)" )
        ))
      (setq org-todo-keyword-faces
	    '(
	      ("TODO" . (:foreground "GoldenRod" :weight bold))
	      ("PLANNING" . (:foreground "DeepPink" :weight bold))
	      ("IN-PROGRESS" . (:foreground "Cyan" :weight bold))
	      ("VERIFYING" . (:foreground "DarkOrange" :weight bold))
	      ("BLOCKED" . (:foreground "Red" :weight bold))
	      ("DONE" . (:foreground "LimeGreen" :weight bold))
	      ("OBE" . (:foreground "LimeGreen" :weight bold))
	      ("WONT-DO" . (:foreground "LimeGreen" :weight bold))
	      ))
    (setq org-capture-templates
	  '(    
	    ("c" "Code To-Do"
	     entry (file+headline "~/org/todos.org" "Code Related Tasks")
	     "* TODO [#B] %?\n:Created: %T\n%i\n%a\nProposed Solution: "
	     :empty-lines 0)
      ("m" "Meeting"
	   entry (file+datetree "~/org/meetings.org")
	   "* %? :meeting:%^g \n:Created: %T\n** Attendees\n*** \n** Notes\n** Action Items\n*** TODO [#A] "
	   :tree-type week
	   :clock-in t
	   :clock-resume t
	   :empty-lines 0)
  ("g" "General To-Do"
	   entry (file+headline "~/org/todos.org" "General Tasks")
	   "* TODO [#B] %?\n:Created: %T\n "
	   :empty-lines 0)
	    ))
