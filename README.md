# Dotfiles

Personal system configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

Supports:
- macOS (personal and work machines)
- Linux (Omarchy)

## Quick Start

### New Machine Setup

Run the bootstrap script to set up a new machine from scratch:

```bash
curl -fsSL https://raw.githubusercontent.com/USERNAME/dotfiles/main/scripts/bootstrap.sh | bash
```

The script will:
1. Install Xcode CLI tools (macOS) or base dependencies (Linux)
2. Install Homebrew (macOS)
3. Install and authenticate GitHub CLI
4. Ask which machine profile to use
5. Clone this repository
6. Run the full installation

### Existing Machine

If you already have the repository cloned:

```bash
cd ~/git/dotfiles
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
├── homebrew/                 # Brewfiles (not stowed)
│   ├── Brewfile.common
│   ├── Brewfile.personal
│   └── Brewfile.work
├── scripts/                  # Installation scripts
│   ├── bootstrap.sh          # Curl-able bootstrap
│   ├── install.sh            # Main installer
│   ├── detect-machine.sh     # Machine profile
│   └── macos-defaults.sh     # macOS system preferences
└── local/                    # Templates for local overrides
    ├── .zshrc.local.example
    └── .gitconfig.local.example
```

## Machine Profiles

The system supports three machine profiles:

| Profile | Description |
|---------|-------------|
| `macos-personal` | Personal MacBook |
| `macos-work` | Work MacBook |
| `linux` | Linux machine |

Profiles are detected automatically or can be set manually:

```bash
DOTFILES_MACHINE=macos-work ./scripts/install.sh
```

## Local Overrides

Machine-specific settings go in `.local` files which are **not tracked by git**:

- `~/.zshrc.local` - Machine-specific shell settings, paths, secrets
- `~/.gitconfig.local` - Git user identity and signing configuration

Templates are provided in the `local/` directory.

### Work Machine Example

For work machines, `~/.zshrc.local` might include:

```zsh
# Corporate proxy
export HTTP_PROXY="http://proxy.work.com:8080"
export HTTPS_PROXY="http://proxy.work.com:8080"

# Work-specific paths
export PATH="/opt/corporate-tools/bin:$PATH"

# Work aliases
alias vpn="open /Applications/Corporate\ VPN.app"
```

And `~/.gitconfig.local`:

```gitconfig
[user]
    name = Your Name
    email = your.name@company.com
```

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

## Updating

```bash
cd ~/git/dotfiles
git pull
./scripts/install.sh
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
