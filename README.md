# dotfiles

Personal macOS dotfiles with a focus on:
- fast [Zsh](https://www.zsh.org/) startup
- XDG-friendly config layout
- reproducible installs via [Homebrew](https://brew.sh/)
- minimal magic, explicit behavior

✅ Tested on [macOS (Apple Silicon)](https://support.apple.com/en-us/116943).

---

## ⏱️ Quick start

```bash
git clone https://github.com/kaffolder7/dotfiles ~/src/dotfiles
cd ~/src/dotfiles
./install.sh --brew
```

This will:
- Install [Homebrew](https://brew.sh/) if missing
- Install packages from [`Brewfile`](Brewfile)
- Symlink dotfiles into your home directory
- Back up any existing files before replacing them

To overwrite existing files without backups:
```shell
./install.sh --brew --force
```

---

## What gets installed / linked

### Zsh
- `~/.zshrc` → `home/.zshrc`
- Modular config loaded from:
  ```
  ~/.config/zsh/zshrc.d/
  ```

<!-- ## Local overrides
- Copy `git/.gitconfig.local.example` to `~/.gitconfig.local` and edit. -->

Features:
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) _([instant prompt](https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#instant-prompt) enabled)_<!-- - [Starship](https://starship.rs/) prompt -->
- Cached completions
- [Autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) + [autocomplete](https://github.com/marlonrichert/zsh-autocomplete)
- [Syntax highlighting](https://github.com/zsh-users/zsh-syntax-highlighting/) (loaded last)
- History + cache under XDG paths
- [`fastfetch`](https://github.com/fastfetch-cli/fastfetch) runs once per session (after prompt)

### Git
- `~/.gitconfig` → `home/.gitconfig`
- Personal settings live in `~/.gitconfig.local` (not committed)

Create it with:
```
cp home/.gitconfig.local.example ~/.gitconfig.local
```

### Ghostty

[Ghostty](https://ghostty.org/) is a fast, feature-rich, and cross-platform terminal emulator that uses platform-native UI and GPU acceleration.
- `~/.config/ghostty/config` → `xdg/ghostty/config`

Includes:
- [JetBrains Mono Nerd Font](https://www.jetbrains.com/lp/mono/)
- [Ayu](https://github.com/ayu-theme/ayu-vim) theme
- Transparent background with blur
- Sensible padding and defaults

### Nano
- `~/.config/nano/nanorc` → `xdg/nano/nanorc`

---

## Homebrew

[Homebrew](https://brew.sh/) is _the_ missing package manager for macOS (or Linux).

All packages are managed via `Brewfile`.
- Safe by default: installs missing packages only
- To enforce a clean system (⚠️ destructive):
  ```
  brew bundle --cleanup
  ```

To update the Brewfile after changes:
```
brew bundle dump --force
```

---

## Local overrides (recommended)

### Zsh

Create a local-only file:
```
cp home/.zshrc.local.example ~/.zshrc.local
```

Anything in `~/.zshrc.local` is sourced last and ignored by git.

### Git

Edit `~/.gitconfig.local` for name, email, signing keys, etc.

---

## Repo layout
```text
dotfiles/
├── Brewfile
├── install.sh
├── codex/
    └── config.toml
├── home/
    ├── .gitconfig
    ├── .gitconfig.local.example
    ├── .zshrc
    └── .zshrc.local.example
├── nix/
    └── home.nix
├── secrets/
├── xdg/
    ├── ghostty/
        └── config
    ├── nano/
        └── nanorc
    └── zsh/
        └── zshrc.d/
            ├── 00-env.zsh
            ├── 10-homebrew.zsh
            ├── 20-completion.zsh
            ├── 30-history.zsh
            ├── 40-aliases.zsh
            ├── 50-prompt.zsh
            ├── 60-plugins.zsh
            ├── 70-openai.zsh
            ├── 80-hooks.zsh
            └── 90-local.zsh
├── .gitignore
├── flake.lock
├── flake.nix
└── README.md
```

---

## Notes
- This repo intentionally avoids [Oh My Zsh](https://ohmyz.sh/) _(...Powerlevel10k is Zsh-native / faster)_
  - _Another option might be to utilize [Oh My Posh](https://ohmypo.sh/)_
- No output is produced before Powerlevel10k instant prompt
- Designed to be safe to re-run multiple times

Clone it, run it, forget about it.