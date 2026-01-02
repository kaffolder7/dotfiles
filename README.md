# dotfiles

Personal macOS dotfiles with a focus on:
- fast [Zsh](https://www.zsh.org/) startup
- XDG-friendly config layout
- reproducible installs via [Homebrew](https://brew.sh/)
- minimal magic, explicit behavior

✅ Tested on macOS (Apple Silicon).
<!-- Tested on [macOS (Apple Silicon)](https://support.apple.com/en-us/116943). -->

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
- `~/.zshrc` → `zsh/.zshrc`
- Modular config loaded from:
  ```
  ~/.config/zsh/zshrc.d/
  ```

<!-- ## Local overrides
- Copy `git/.gitconfig.local.example` to `~/.gitconfig.local` and edit. -->

Features:
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) _(instant prompt enabled)_<!-- - [Starship](https://starship.rs/) prompt -->
- Cached completions
- Autosuggestions + autocomplete
- Syntax highlighting (loaded last)
- History + cache under XDG paths
- `fastfetch` runs once per session (after prompt)

### Git
- `~/.gitconfig` → `git/.gitconfig`
- Personal settings live in `~/.gitconfig.local` (not committed)

Create it with:
```
cp git/.gitconfig.local.example ~/.gitconfig.local
```

### [Ghostty](https://ghostty.org/)

Ghostty is a fast, feature-rich, and cross-platform terminal emulator that uses platform-native UI and GPU acceleration.
- `~/.config/ghostty/config` → `ghostty/config`

Includes:
- [JetBrains Mono Nerd Font](https://www.jetbrains.com/lp/mono/)
- [Ayu](https://github.com/ayu-theme/ayu-vim) theme
- Transparent background with blur
- Sensible padding and defaults

### Nano
- `~/.config/nano/nanorc` → `nano/nanorc`

---

## Homebrew

The Missing Package Manager for macOS (or Linux).

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
cp zsh/.zshrc.local.example ~/.zshrc.local
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
├── git/
├── ghostty/
├── nano/
└── zsh/
    ├── .zshrc
    ├── .zshrc.local.example
    └── zshrc.d/
```

---

## Notes
- This repo intentionally avoids [Oh My Zsh](https://ohmyz.sh/) _(...Powerlevel10k is Zsh-native / faster)_
  - _Another option might be to utilize [Oh My Posh](https://ohmypo.sh/)_
- No output is produced before Powerlevel10k instant prompt
- Designed to be safe to re-run multiple times

Clone it, run it, forget about it.