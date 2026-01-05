# dotfiles 🧰

Personal macOS dotfiles with a focus on:
- ⚡ fast [Zsh](https://www.zsh.org/) startup
- 🗂️ XDG-friendly config layout
- ♻️ reproducible installs via [Homebrew](https://brew.sh/)
- 🔍 minimal magic, explicit behavior

✅ Tested on [macOS (Apple Silicon)](https://support.apple.com/en-us/116943).

---

## ⏱️ Quick start

```bash
git clone https://github.com/kaffolder7/dotfiles ~/src/dotfiles
cd ~/src/dotfiles
./install.sh --brew
```

This will:
- Install [Homebrew](https://brew.sh/) (if missing)
- Install packages from [`Brewfile`](Brewfile)
- Symlink dotfiles into your home directory
- Back up any existing files before replacing them

To overwrite existing files without backups:
```shell
./install.sh --brew --force
```

<!-- After setup, run `dot doctor` to sanity-check the environment. -->
After install, you can sanity-check everything with: `dot doctor`.

---

## 🩺 Dotfiles doctor

A small built-in sanity check for this repo.

After installation, you can run:

```bash
dot doctor
```

This verifies:
- which install route is active (Homebrew vs Home Manager)
- required XDG paths exist and are writable
- required cache and history directories are present
- file-based secrets are set up correctly
- expected tools (`llm`, `codex`, etc.) are available

Think of it like `brew doctor`, but scoped specifically to _this_ dotfiles repo.

It’s safe to run anytime and is especially useful:
- after a fresh install
- when switching machines
- if something feels “off” with your shell

It does not print secret values — only presence and basic health checks.

---

## Installation routes

This repo supports two install styles:

### 🧪 Homebrew (default)
Recommended for most macOS setups.

- Uses `install.sh --brew`
- Zsh config is loaded directly from `~/.zshrc`
- Homebrew manages all packages

### 🧬 Home Manager (optional / advanced)
For users already using Nix + Home Manager.

- Zsh is managed via `nix/home.nix`
- Dotfiles are still shared, but loaded via Home Manager
- `DOTFILES_ROUTE=hm` is set automatically

Both routes share the same Zsh modules and XDG layout.

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
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) _([instant prompt](https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#instant-prompt) enabled)_ 🚀<!-- - [Starship](https://starship.rs/) prompt -->
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

## 🧪 Homebrew

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

## 🔐 Secrets

Secrets are stored as files (not env vars) under: `~/.config/secrets/`.

Examples:
- `openai_api_key_llm`
- `openai_api_key_codex`

They are:
- ignored by git
- read only when needed
- injected per-command (not exported globally)

See `xdg/zsh/zshrc.d/70-openai.zsh` for details.

---

## 🧩 Local overrides (recommended)

### Zsh

Create a local-only file:
```
cp home/.zshrc.local.example ~/.zshrc.local
```

Anything in `~/.zshrc.local` is sourced last and ignored by git.

### Git

Edit `~/.gitconfig.local` for name, email, signing keys, etc.

---

## 🗺️ Repo layout
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

## 📝 Notes
- Intentionally avoids [Oh My Zsh](https://ohmyz.sh/) _(...Powerlevel10k is Zsh-native / faster)_<!-- - _Another option might be to utilize [Oh My Posh](https://ohmypo.sh/)_ -->
- No output is produced before Powerlevel10k instant prompt
- Designed to be safe to re-run multiple times

Clone it, run it, forget about it. ✨