# Dotfiles

Homebrew-first macOS development setup for a MacBook Pro and Mac mini.
Git stores configuration, Homebrew installs tools and apps, mise selects Node
versions, and uv manages Python.

## Start here

- **Moving from Nix?** Follow the [migration guide](docs/migration.md) first.
- **New Mac?** Follow the setup steps below.
- [1Password SSH and CLI](docs/1password.md)
- [Node, Python, Java, and Happy](docs/runtimes.md)
- [What replaced each Nix setting](docs/parity.md)

## Set up a Mac

Install Apple's Command Line Tools and [Homebrew](https://brew.sh/). Use a
separate Git clone on each Mac, excluded from Syncthing.

```sh
git clone https://github.com/kaffolder7/dotfiles.git ~/Projects/Personal/dotfiles
cd ~/Projects/Personal/dotfiles
./install.sh --host mbp --brew --dry-run
./install.sh --host mbp --brew
```

Use `--host macmini` on the Mac mini. Open a new terminal and run `dot doctor`.
Then complete the [1Password setup](docs/1password.md) on that Mac.

The installer installs missing dependencies before activating configuration.
Installation does not deliberately upgrade existing packages. Replaced files
are backed up privately under `~/.local/state/dotfiles/backups/`. If activation
fails, originals are restored. Package installations are not rolled back.

Nix removal is a separate final step. Docker credentials, editor settings, the
Codex desktop app and its configuration, and Happy account data are preserved.

## Everyday use

| Task | Command |
|---|---|
| Check packages, PATH, Java, and SSH | `dot doctor` |
| Verify 1Password authentication interactively | `dot doctor --auth` |
| Inventory tools and Nix dependencies | `dot audit` |
| Install missing tools after pulling changes | `dot install --brew` |
| Reapply configuration without installing packages | `dot install` |
| Update declared packages and Node 24 patches | `dot update` |
| Test the repository | `make test` |

Updates leave unrelated installed packages alone. Happy has a reviewed version
in the mise configuration; bump it deliberately. Python updates stay within 3.14.

Add shared tools to `Brewfile`, commit, pull on the other Mac, then run
`dot install --brew` there. Keep project dependencies in their own repositories.

### Optional VS Code

Zed is the graphical editor. Neovim is the terminal editor. To install VS Code
and the retained extension list, run `dot install --brew --with-vscode`.
The choice is recorded locally and included in later updates.

The shell alias `code` opens Zed. Use VS Code's actual executable for VS Code.

## Personal settings

| File | Purpose |
|---|---|
| `~/.gitconfig.local` | Identity and optional signing |
| `~/.zshrc.local` | Interactive shell overrides |
| `~/.zshenv.local` | Quiet environment settings for every Zsh process |
| `~/.zprofile.local` | Login-shell additions |
| `~/.ssh/config.local` | SSH hosts and per-host overrides |
| `~/.config/ghostty/config.local` | Terminal overrides |
| `~/.p10k.zsh` | Existing personal prompt override |
| `~/.config/dotfiles/host` | Installer-managed host selection |

The installer honors absolute `XDG_CONFIG_HOME`, `XDG_STATE_HOME`, and
`XDG_BIN_HOME` paths. Most shared files link into the checkout. Edit shared
defaults here and keep personal values in the local files above.

GitHub CLI configuration remains writable. Nano configuration is generated
with the local Homebrew syntax-definition path.

Normal `codex` keeps its existing sign-in. Optional `codex-openai` and
`llm-openai` helpers read per-command keys from `~/.config/secrets/`.
Keep actual key files private with mode `600`. The optional `llm` tool is not
installed by default.

## Repository layout

| Location | Contents |
|---|---|
| `Brewfile`, `Brewfile.vscode` | Shared tools and optional editor |
| `home/` | Home-directory entry points and SSH configuration |
| `xdg/` | Shell, terminal, tool, and runtime preferences |
| `bin/` | `dot` and compatibility `dot-doctor` commands |
| `scripts/`, `tests/` | Bootstrap, diagnostics, and isolated tests |
| `docs/` | Migration, parity, runtime, and 1Password guides |

The Nix configuration is archived at `nix-home-manager-final-2026-11-12`.
