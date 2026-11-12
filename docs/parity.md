# Nix migration checklist

The source snapshot is `nix-home-manager-final-2026-11-12`. This ledger covers
enabled configuration, not the many commented examples in the old Nix files.

## Packages

| Previous package or module | Replacement |
|---|---|
| backblaze-b2 | Homebrew `b2-tools`; executable is `b2` |
| bat, bbrew, curl, ddev, direnv | Same Homebrew tools |
| docker-cli | Homebrew `docker`; existing OrbStack context/data retained |
| eza, fastfetch, fd, fzf | Same Homebrew tools and shell integration |
| git, git-lfs, gh, jq | Same Homebrew tools |
| neovim, nano | Same Homebrew tools; Neovim aliases restored |
| ripgrep, uv, zoxide | Same Homebrew tools |
| mkcert, nss, repomix, yt-dlp | Same Homebrew tools |
| codex, programs.codex | Homebrew `codex` CLI cask; existing settings preserved |
| zed-editor | Homebrew Zed cask; existing user settings preserved |
| zsh and shell plugins | macOS `/bin/zsh` plus Homebrew autosuggestions/highlighting |
| zsh-powerlevel10k | Homebrew `powerlevel10k` plus existing prompt override |
| nodejs_24 | mise Node 24 default; projects can select other versions |
| python314 | uv-managed Python 3.14; existing uv installs retained |
| Java 25 | Homebrew `openjdk@25` and user JDK registration |
| llm-agents.happy-coder | mise `npm:happy`, currently 1.2.6 |
| nil, nixd, nix-prefetch-github, home-manager | Retired Nix-only tools |
| nix-direnv | Removed; ordinary direnv retained |

Existing active Brewfile entries are retained except obsolete packaging and
Nix-only extensions. VS Code extensions moved to `Brewfile.vscode`.
Homebrew marks `codex-app` discontinued; keep the existing Codex desktop
installation and its vendor updater. The CLI is separately managed.
1Password app/CLI and Ghostty are explicit dependencies.

The original zsh-autocomplete declaration was not active under Home Manager.
It is optional in local shell configuration rather than enabled during migration.
Ollama was not enabled in Nix or the Brewfile. The old installer silently
installed it anyway; that behavior and its unused model-download script are removed.
Manually installed Ollama, Syncthing, Claude, Java 21, and other tools remain.

## Configuration

| Previous responsibility | Replacement |
|---|---|
| XDG and session variables | Quiet Zsh environment, including state/data paths |
| Per-host modules | Local host selection; shared package set on both Macs |
| Bat theme, style, pager | Tracked bat config |
| fd hidden files and ignores | Alias plus tracked ignore file |
| ripgrep hidden/smart-case settings | Tracked config plus environment variable |
| fzf options and fd source | Environment variables plus shell hook |
| Git defaults, LFS, diff/merge behavior | Managed Git defaults plus preserved personal overrides |
| GitHub helpers pointing into Nix | `!gh auth git-credential` using Homebrew |
| GitHub protocol and prompt | Writable gh config; credentials untouched |
| SSH includes and 1Password agent | Managed SSH config with direct macOS socket |
| 1Password socket compatibility link | Direct link to the live desktop socket |
| Java registration | User JDK symlink and explicit `JAVA_HOME` |
| History and shell aliases | Shared Zsh modules, existing history path retained |
| Completion, autosuggestions, highlighting | Homebrew-backed shell initialization |
| Zoxide and direnv | Hooks restored without Nix |
| Powerlevel10k | Shared fallback; existing `~/.p10k.zsh` wins |
| Garmin SDK discovery | Version-sorted existing SDK directories |
| Ghostty config and One Dark | Tracked files, optional local include |
| Nano syntax/settings | Generated local include plus shared settings |
| dot and dot-doctor | Repository-resolving commands |
| Docker JSON and application data | Existing mutable data preserved |
| DDEV's existing XDG configuration | Selected with `DDEV_XDG_CONFIG_HOME` when present |
| Home Manager fonts marker and .keep files | Backed up and retired if still linked into Nix |

One Dark's palette comes from [avesst/ghostty-onedark](https://github.com/avesst/ghostty-onedark),
previously supplied by the flake input. Its active palette was preserved.

## Verification record

`make test` covers isolated activation and preservation. Each machine still
needs `dot doctor --no-nix`, 1Password authorization, representative project
checks, and a Happy phone-session test before Nix removal.

A Git tag saves configuration history. It does not back up installed Nix packages,
private credentials, or application databases.
