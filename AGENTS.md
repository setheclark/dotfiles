# Agent Instructions

## Core Requirement: Idempotency

All changes made to this repository must result in **idempotent behavior**. Scripts, stow operations, and config changes must be safe to apply multiple times without unintended side effects.

### What this means in practice

- **Install scripts**: Running `install.sh` (or any setup script) a second time must produce the same end state as running it once. No duplicate entries, no errors on re-run.
- **Stow operations**: GNU Stow is used to manage symlinks. Do not add manual symlink creation that conflicts with or duplicates stow-managed links.
- **Shell config**: Do not append to files like `.zshrc` or `.bashrc` without first checking whether the content is already present. Prefer sourcing a managed file over inline additions.
- **Homebrew**: Do not `brew install` packages that are already managed in `Brewfile`. Add packages to the appropriate `Brewfile` instead.
- **Package managers / tool installs**: Wrap installs with existence checks (e.g., `command -v foo || brew install foo`).
- **File writes**: Prefer idempotent config formats (TOML, YAML, symlinks) over scripts that append to files.

### Checklist before committing

- [ ] Can the install/setup script be run twice on a clean system without error?
- [ ] Are new packages added to `Brewfile` rather than installed ad-hoc?
- [ ] Are new dotfiles placed under a stow package directory so stow manages the symlink?
- [ ] Are any file-append operations guarded against duplication?

## Repository Structure

- `homebrew/Brewfile` — Homebrew packages (taps, brews, casks, Mac App Store apps)
- `<package>/` — Dotfile packages managed by GNU Stow; each top-level directory (e.g. `zsh/`, `git/`, `nvim/`) is a stow package rooted at `$HOME`
- `scripts/install.sh` — Idempotent bootstrap script
- `scripts/macos-defaults.sh` — macOS system preferences script
- `README.md` — Human-readable setup instructions
