;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john.doe@example.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font (font-spec :family "JetBrains Mono" :size 12 :weight 'regular)
      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-monokai-pro)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Documents/org/")

;; Show sideline symbols info.
(after! lsp-ui
  (setq lsp-ui-sideline-show-hover t))

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Enable Gravatars for Magit
(after! magit
  (setq magit-revision-show-gravatars '("^Author:     " . "^Commit:     ")))

;; Load magit-todos after Magit
(use-package! magit-todos
  :defer t
  :init (after! magit (require 'magit-todos))
  :config (magit-todos-mode 1))

;; Add prometheus mode
(use-package! prometheus-mode
  :defer t)

;; Accept completion from copilot and fallback to corfu
(use-package! copilot
  :defer t
  :init (after! prog-mode (require 'copilot))
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word)))

;; Enable flyover mode for flycheck
;; (use-package! flyover
;;   :defer t
;;   :init (after! flycheck-mode (require 'flyover))
;;   :hook (flycheck-mode . flyover-mode)
;;   :config
;;   (setq flyover-levels '(error warning info)
;;         flyover-use-theme-colors t
;;         flyover-background-lightness 45
;;         flyover-percent-darker 40
;;         flyover-text-tint 'lighter
;;         flyover-text-tint-percent 50
;;         flyover-virtual-line-type 'straight-arrow))

;; Enable evil-numbers for incrementing/decrementing numbers
(use-package! evil-numbers
  :defer t
  :init (after! evil (require 'evil-numbers))
  :bind (:map evil-normal-state-map
              ("C-+" . 'evil-numbers/inc-at-pt)
              ("C--" . 'evil-numbers/dec-at-pt)))

;; Enable protobuf mode for .proto files
(use-package! protobuf-mode
  :defer t
  :mode ("\\.proto\\'" . protobuf-mode))

;; Custom function(s) to open terminal in current directory
(defun my/get-terminal-command ()
  "Get the appropriate terminal command for the current OS."
  (cond
   ;; Check for ghostty first (cross-platform)
   ((executable-find "ghostty") "ghostty")
   ;; macOS specific terminals
   ((eq system-type 'darwin)
    (cond
     ((file-exists-p "/Applications/iTerm.app") "iterm2")
     (t "terminal"))) ; macOS default Terminal
   ;; Linux terminals
   ((executable-find "konsole") "konsole")
   ;; Final fallback
   (t "xterm")))

(defun my/open-terminal-here ()
  "Open terminal in current directory."
  (interactive)
  (let* ((dir (if (buffer-file-name)
                  (file-name-directory (buffer-file-name))
                default-directory))
         (terminal (my/get-terminal-command))
         (cmd (cond
               ;; Ghostty (cross-platform)
               ((string-match "ghostty" terminal)
                (format "%s --working-directory=%s" terminal (shell-quote-argument dir)))

               ;; macOS terminals using AppleScript
               ((string-match "iterm2" terminal)
                (format "osascript -e 'tell application \"iTerm2\"' -e 'create window with default profile' -e 'tell current session of current window' -e 'write text \"cd %s\"' -e 'end tell' -e 'end tell'"
                        (shell-quote-argument dir)))

               ((string-match "terminal" terminal)
                (format "osascript -e 'tell application \"Terminal\"' -e 'do script \"cd %s\"' -e 'end tell'"
                        (shell-quote-argument dir)))

               ;; Linux terminals
               ((string-match "konsole" terminal)
                (format "%s --workdir %s" terminal (shell-quote-argument dir)))

               ;; Final fallback
               (t (format "%s -e 'cd %s'" terminal (shell-quote-argument dir))))))
    (start-process "terminal" nil "sh" "-c" cmd)))

(map! :leader
      :desc "Open terminal here"
      "o t" #'my/open-terminal-here)

;; Custom function(s) to open diffs and merge conflicts in Kompare
(defun my/magit-kompare-diff ()
  "Open diff in Kompare based on context."
  (interactive)
  (if (not (executable-find "kompare"))
      (call-interactively #'magit-ediff-dwim)
    (let ((commit-at-point (magit-commit-at-point)))
      (if commit-at-point
          (my/magit-kompare-commit-vs-head commit-at-point)
        (my/magit-kompare-select-commits)))))

(defun my/magit-kompare-commit-vs-head (commit)
  "Compare COMMIT with HEAD using Kompare."
  (let* ((files (magit-changed-files commit "HEAD")))
    (if (null files)
        (message "No differences between %s and HEAD" (magit-rev-abbrev commit))
      (if (= (length files) 1)
          (my/magit-kompare-file-between-commits (car files) commit "HEAD")
        (let ((file (magit-completing-read "File to diff" files)))
          (my/magit-kompare-file-between-commits file commit "HEAD"))))))

(defun my/magit-kompare-select-commits ()
  "Select two commits/refs to compare in Kompare."
  (interactive)
  (let* ((rev1 (magit-read-branch-or-commit "First commit/ref"))
         (rev2 (magit-read-branch-or-commit "Second commit/ref" rev1))
         (files (magit-changed-files rev1 rev2)))
    (if (null files)
        (message "No differences between %s and %s" rev1 rev2)
      (if (= (length files) 1)
          (my/magit-kompare-file-between-commits (car files) rev1 rev2)
        (let ((file (magit-completing-read "File to diff" files)))
          (my/magit-kompare-file-between-commits file rev1 rev2))))))

(defun my/magit-kompare-file-between-commits (file rev1 rev2)
  "Compare FILE between REV1 and REV2 using Kompare."
  (let* ((rev1-short (magit-rev-abbrev rev1))
         (rev2-short (magit-rev-abbrev rev2))
         (file-base (file-name-nondirectory file))
         (file-dir (file-name-directory file))
         (safe-dir (if file-dir
                       (replace-regexp-in-string "[^a-zA-Z0-9_-]" "_" file-dir)
                     ""))
         (temp1 (make-temp-file (format "%s_%s_%s" rev1-short safe-dir file-base)))
         (temp2 (make-temp-file (format "%s_%s_%s" rev2-short safe-dir file-base))))

    (with-temp-file temp1
      (condition-case nil
          (magit-git-insert "show" (concat rev1 ":" file))
        (error "")))

    (with-temp-file temp2
      (condition-case nil
          (magit-git-insert "show" (concat rev2 ":" file))
        (error "")))

    (start-process "kompare" nil "kompare" temp1 temp2)

    (run-at-time "15 sec" nil
                 (lambda ()
                   (ignore-errors (delete-file temp1))
                   (ignore-errors (delete-file temp2))))))

(defun my/magit-kompare-merge-conflict ()
  "Open merge conflict in Kompare for easier resolution."
  (interactive)
  (if (not (executable-find "kompare"))
      (call-interactively #'magit-ediff-resolve)
    (when-let ((file (magit-file-at-point)))
      (if (magit-file-status file)
          (let* ((file-base (file-name-nondirectory file))
                 (file-dir (file-name-directory file))
                 (safe-dir (if file-dir
                               (replace-regexp-in-string "[^a-zA-Z0-9_-]" "_" file-dir)
                             ""))
                 (temp-ours (make-temp-file (format "OURS_%s%s" safe-dir file-base)))
                 (temp-theirs (make-temp-file (format "THEIRS_%s%s" safe-dir file-base))))

            (with-temp-file temp-ours
              (condition-case nil
                  (magit-git-insert "show" (concat ":2:" file))
                (error "")))

            (with-temp-file temp-theirs
              (condition-case nil
                  (magit-git-insert "show" (concat ":3:" file))
                (error "")))

            (start-process "kompare" nil "kompare" temp-ours temp-theirs)

            (run-at-time "15 sec" nil
                         (lambda ()
                           (ignore-errors (delete-file temp-ours))
                           (ignore-errors (delete-file temp-theirs)))))
        (message "No merge conflict in this file")))))

(defun my/magit-gitkraken-open ()
  "Open current repository in GitKraken."
  (interactive)
  (if (not (executable-find "gitkraken"))
      (message "GitKraken not found")
    (let ((repo-path (magit-toplevel)))
      (if repo-path
          (progn
            (start-process "gitkraken" nil "gitkraken" "--path" repo-path)
            (message "Opened repository in GitKraken"))
        (message "Not in a Git repository")))))

(with-eval-after-load 'magit
  (define-key magit-mode-map (kbd "C-c k") #'my/magit-kompare-diff)
  (define-key magit-mode-map (kbd "C-c M") #'my/magit-kompare-merge-conflict)
  (define-key magit-mode-map (kbd "C-c g") #'my/magit-gitkraken-open))
