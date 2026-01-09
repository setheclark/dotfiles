# Dotfiles

Personal macOS system configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick Start

### New Machine Setup

Run the install script to set up a new macOS machine from scratch:

```bash
curl -fsSL https://raw.githubusercontent.com/USERNAME/dotfiles/main/scripts/install.sh | bash
```

The script will:
1. Install Xcode Command Line Tools
2. Install Homebrew
3. Install and authenticate GitHub CLI
4. Install all Homebrew packages
5. Stow dotfiles configurations
6. Set up shell and local overrides

The script is **idempotent** - safe to run multiple times.

### Updating Existing Installation

```bash
cd ~/git/dotfiles
git pull
./scripts/install.sh
```

## Theme

All themeable tools use [Catppuccin Frappe](https://github.com/catppuccin/catppuccin) for a consistent look.

**Themed tools:**
- Ghostty (terminal emulator)
- Starship prompt
- Neovim (via lazy.nvim plugin)
- bat (syntax highlighting)
- delta (git diffs)
- lazygit
- fzf

When adding new tools, prefer Catppuccin Frappe if a theme is available.

## Structure

```
dotfiles/
├── zsh/                      # Zsh shell configuration
│   ├── .zshrc
│   └── .zsh/
│       ├── aliases.zsh
│       ├── functions.zsh
│       └── path.zsh
├── git/                      # Git configuration
│   ├── .gitconfig
│   └── .config/git/ignore
├── nvim/                     # Neovim configuration
│   └── .config/nvim/init.lua
├── starship/                 # Starship prompt
│   └── .config/starship.toml
├── bat/                      # bat configuration
│   └── .config/bat/config
├── lazygit/                  # lazygit configuration
│   └── .config/lazygit/config.yml
├── ghostty/                  # Ghostty terminal emulator
│   └── .config/ghostty/config
├── ssh/                      # SSH configuration
│   └── .ssh/
│       ├── config
│       └── config.d/
├── homebrew/                 # Brewfile (not stowed)
│   └── Brewfile              # All Homebrew packages
├── scripts/                  # Installation scripts
│   ├── install.sh            # Unified installer (idempotent)
│   └── macos-defaults.sh     # macOS system preferences
└── local/                    # Templates for local overrides
    ├── .zshrc.local.example
    └── .gitconfig.local.example
```

## Local Overrides

Machine-specific settings go in `.local` files which are **not tracked by git**:

- `~/.zshrc.local` - Machine-specific shell settings, paths, secrets, extra packages
- `~/.gitconfig.local` - Git user identity and work repository configuration

Templates are provided in the `local/` directory.

### Example: Machine-Specific Overrides

`~/.zshrc.local` for machine-specific customizations:

```zsh
# Corporate proxy
export HTTP_PROXY="http://proxy.work.com:8080"
export HTTPS_PROXY="http://proxy.work.com:8080"

# Machine-specific paths
export PATH="/opt/corporate-tools/bin:$PATH"

# Install machine-specific packages
# brew install terraform aws-cli kubectl
```

### Example: Work Repository Git Configuration

The install script sets up your git identity in `~/.gitconfig.local` and optionally configures automatic work email switching using git's conditional includes.

If you specified a work email during installation, git will automatically use your work email for repositories owned by your company:

```gitconfig
[user]
    name = Your Name
    email = your.personal@email.com

# Work repository configuration
# Automatically uses work email for repos owned by: company

# SSH remotes: git@github.com:company/*
[includeIf "hasconfig:remote.*.url:git@github.com:company/**"]
    path = ~/.gitconfig.work

# HTTPS remotes: https://github.com/company/*
[includeIf "hasconfig:remote.*.url:https://github.com/company/**"]
    path = ~/.gitconfig.work
```

Where `~/.gitconfig.work` contains:

```gitconfig
[user]
    email = your.work@company.com
```

This way, personal repos use your personal email, and work repos automatically use your work email.

## Secrets Management

Secrets are managed via 1Password CLI. Install it:

```bash
brew install 1password-cli
op account add
```

Use secrets in your shell:

```zsh
# In ~/.zshrc.local
export API_KEY=$(op read "op://Personal/Service/api-key")
```

## Adding New Configurations

1. Create a new directory for the package:
   ```bash
   mkdir -p newpackage/.config/newapp
   ```

2. Add configuration files mirroring the home directory structure:
   ```bash
   # Files will be symlinked to ~/.config/newapp/config
   vim newpackage/.config/newapp/config
   ```

3. Stow the package:
   ```bash
   stow -v newpackage
   ```

## Manual Stow Commands

```bash
# Stow a single package
stow -v --target=$HOME zsh

# Restow (useful after changes)
stow -v --restow --target=$HOME zsh

# Unstow (remove symlinks)
stow -v --delete --target=$HOME zsh

# Dry run (preview changes)
stow -v --no --target=$HOME zsh
```

## Tools Included

| Tool | Description |
|------|-------------|
| [starship](https://starship.rs/) | Cross-shell prompt |
| [eza](https://github.com/eza-community/eza) | Modern ls replacement |
| [bat](https://github.com/sharkdp/bat) | Cat with syntax highlighting |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast grep alternative |
| [fd](https://github.com/sharkdp/fd) | Fast find alternative |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter cd |
| [delta](https://github.com/dandavison/delta) | Better git diffs |
| [lazygit](https://github.com/jesseduffield/lazygit) | Terminal UI for git |

## License

MIT
