# Run (if `home-manager` is on `PATH`):
#  - `home-manager switch --flake .#macmini`, or...
#  - `home-manager switch --flake .#mbp`
{
  pkgs,
  lib,
  username,
  ghosttyOneDark,
  ...
}:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # atuin
    # Replacement for a shell history which records additional commands context with optional encrypted synchronization between machines
    # pkgs.atuin

    # atuin-desktop
    # Local-first, executable runbook editor
    # pkgs.atuin-desktop

    # axel
    # Console downloading program with some features for parallel connections for faster downloading
    # pkgs.axel

    # Backblaze B2
    # Command-line tool for accessing the Backblaze B2 storage service
    pkgs.backblaze-b2

    # Bat is a better `cat`.
    # Get syntax highlighting, line numbers, and Git integration.
    pkgs.bat

    # bbrew
    # The modern Terminal UI for managing Homebrew packages and casks on macOS and Linux.
    # (pkgs.callPackage ./pkgs/bbrew.nix { })
    pkgs.bbrew

    # broot
    # Interactive tree view, a fuzzy search, a balanced BFS descent and customizable commands
    # pkgs.broot

    # claude-code
    # Agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster
    pkgs.claude-code

    # claude-monitor
    # Real-time Claude Code usage monitor
    # pkgs.claude-monitor

    # (OpenAI) Codex CLI
    # Lightweight coding agent that runs in your terminal
    pkgs.codex

    # colima
    # Container runtimes with minimal setup
    # pkgs.colima

    # curl
    # Command line tool for transferring files with URL syntax
    pkgs.curl

    # ddev
    # Docker-based local PHP+Node.js web development environments
    pkgs.ddev

    # direnv
    # Shell extension that manages your environment
    pkgs.direnv

    # docker
    # Open source project to pack, ship and run any application as a lightweight container
    pkgs.docker

    # doppler
    # Official CLI for interacting with your Doppler Enclave secrets and configuration
    # pkgs.doppler

    # Eza is a better `ls`.
    # Get colors, icons, tree views, Git status.
    pkgs.eza

    # FastFetch
    # Fetches system information and displays it in a visually appealing way.
    pkgs.fastfetch

    # fd
    # Simple, fast and user-friendly alternative to find
    pkgs.fd

    # ffmpeg
    # Complete, cross-platform solution to record, convert and stream audio and video
    # pkgs.ffmpeg

    # fzf
    # Command-line fuzzy finder written in Go
    # pkgs.fzf

    # gh
    # GitHub CLI tool
    pkgs.gh

    # git
    # Distributed version control system
    pkgs.git

    # git-lfs
    # Git extension for versioning large files
    pkgs.git-lfs

    # gnupg
    # Modern release of the GNU Privacy Guard, a GPL OpenPGP implementation
    # pkgs.gnupg

    # helix
    # Post-modern modal text editor
    # pkgs.helix

    # Provides `telnet`
    # pkgs.inetutils

    # jq
    # Lightweight and flexible command-line JSON processor
    pkgs.jq

    # LLM
    # Access large language models from the command-line
    # pkgs.llm
    # pkgs.llm.withPlugins [ ... ]
    # (pkgs.llm.withPlugins [ /* plugin derivations here */ ])

    # mkcert
    # Simple tool for making locally-trusted development certificates
    pkgs.mkcert

    # nano
    # Small, user-friendly console text editor
    pkgs.nano

    # nanorc
    # Improved Nano Syntax Highlighting Files
    # pkgs.nanorc

    # Neovim
    # Vim-fork focused on extensibility and usability
    pkgs.neovim

    # nil
    # Yet another language server for Nix (necessary for Zed editor?)
    pkgs.nil

    # nixd
    # Feature-rich Nix language server interoperating with C++ nix (necessary for Zed editor?)
    pkgs.nixd

    # nix-prefetch-github
    # Prefetch sources from github
    pkgs.nix-prefetch-github

    # nodejs_24
    # Event-driven I/O framework for the V8 JavaScript engine
    # pkgs.nodejs_24

    # nodenv
    # Manage multiple NodeJS versions
    # pkgs.nodenv

    # nodeenv
    # Node.js virtual environment builder
    # pkgs.nodeenv

    # nss
    # Set of libraries for development of security-enabled client and server applications (necessary for `mkcert`)
    pkgs.nss

    # ollama
    # Get up and running with large language models locally
    # pkgs.ollama

    # opencode
    # AI coding agent built for the terminal
    # pkgs.opencode

    # openllm
    # Run any open-source LLMs, such as Llama 3.1, Gemma, as OpenAI compatible API endpoint in the cloud
    # pkgs.openllm

    # orbstack
    # Fast, light, and easy way to run Docker containers and Linux machines
    # pkgs.orbstack

    # pandoc
    # Conversion between documentation formats
    # pkgs.pandoc

    # pass
    # Stores, retrieves, generates, and synchronizes passwords securely
    # pkgs.pass

    # pyenv
    # Simple Python version management
    # pkgs.pyenv

    # python314
    # High-level dynamically-typed programming language
    # pkgs.python314

    # repomix
    # Tool to pack repository contents to single file for AI consumption
    pkgs.repomix

    # ripgrep
    # Utility that combines the usability of The Silver Searcher with the raw speed of grep
    pkgs.ripgrep

    # speedtest-cli
    # Command line interface for testing internet bandwidth using speedtest.net
    # pkgs.speedtest-cli

    # stow
    # Tool for managing the installation of multiple software packages in the same run-time directory tree
    # pkgs.stow

    # syncthing
    # Open Source Continuous File Synchronization
    # pkgs.syncthing

    # syncthing-macos
    # Official frugal and native macOS Syncthing application bundle
    # pkgs.syncthing-macos

    # tmux
    # Terminal multiplexer
    # pkgs.tmux

    # uv
    # Extremely fast Python package installer and resolver, written in Rust
    # pkgs.uv

    # High-throughput and memory-efficient inference and serving engine for LLMs
    # pkgs.vllm

    # VS Code extensions
    # pkgs.vscode-extensions.alefragnani.bookmarks
    # pkgs.vscode-extensions.anthropic.claude-code
    # pkgs.vscode-extensions.bbenoist.nix
    # pkgs.vscode-extensions.dbaeumer.vscode-eslint
    # pkgs.vscode-extensions.editorconfig.editorconfig
    # pkgs.vscode-extensions.esbenp.prettier-vscode
    # pkgs.vscode-extensions.github.vscode-github-actions
    # pkgs.vscode-extensions.jgclark.vscode-todo-highlight
    # pkgs.vscode-extensions.mechatroner.rainbow-csv
    # pkgs.vscode-extensions.mikestead.dotenv
    # pkgs.vscode-extensions.ms-python.debugpy
    # pkgs.vscode-extensions.ms-python.python
    # pkgs.vscode-extensions.ms-python.vscode-pylance
    # pkgs.vscode-extensions.ms-vscode-remote.vscode-remote-extensionpack
    # pkgs.vscode-extensions.teabyii.ayu

    # wget
    # Tool for retrieving files using HTTP, HTTPS, and FTP
    # pkgs.wget

    # yt-dlp
    # Feature-rich command-line audio/video downloader
    # pkgs.yt-dlp

    # zed-editor
    # High-performance, multiplayer code editor from the creators of Atom and Tree-sitter
    # pkgs.zed-editor

    # Zoxide
    # Fast cd command that learns your habits
    pkgs.zoxide

    # zsh-powerlevel10k
    # Fast reimplementation of Powerlevel9k ZSH theme
    pkgs.zsh-powerlevel10k
  ];

  ############################################
  # Zsh
  ############################################
  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;

    # Keep this minimal for speed
    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      extended = true;
    };

    initContent = lib.mkMerge [
      # 500: very early (instant prompt must be above any output)
      (lib.mkOrder 500 ''
        # Powerlevel10k instant prompt (must be near the top)
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi

        # Interactive-only from here down
        [[ -o interactive ]] || return

        export XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.cache}"
        export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
      '')

      # 550: before completion init (HM will run compinit; you can set styles here)
      (lib.mkOrder 550 ''
        # ---- Performance knobs ----
        mkdir -p "$XDG_CACHE_HOME/zsh" "$XDG_CACHE_HOME/zsh/zcompcache"
        export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

        # Completion caching helps a lot (set styles before compinit)
        zstyle ':completion:*' use-cache on
        zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
        zstyle ':completion:*' rehash true  # Reduce completion chattiness/overhead a bit

        # Helps with menu selection / nicer completion lists
        zmodload zsh/complist 2>/dev/null || true
      '')

      # 950: add a “mode” flag in HM and gate Brew modules
      (lib.mkOrder 950 ''
        export DOTFILES_ROUTE="hm"
      '')

      # 1000: general init — source your modular files (this is the missing piece)
      (lib.mkOrder 1000 ''
        local ZSHRC_DIR="$XDG_CONFIG_HOME/zsh/zshrc.d"
        if [[ -d "$ZSHRC_DIR" ]]; then
          for f in "$ZSHRC_DIR"/*.zsh(N); do
            source "$f"
          done
        fi
        unset f
      '')

      # 1500: last — hooks, one-time fastfetch, etc.
      (lib.mkOrder 1500 ''
        # Disable the p10k wizard entirely – even with the file managed (`../xdg/zsh/.p10k.zsh`), this prevents surprises on new machines
        typeset -g POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

        # ---- Prompt (P10k) ----
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        # [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
        [[ -r "${"ZDOTDIR:-$HOME"}/.p10k.zsh" ]] && source "${"ZDOTDIR:-$HOME"}/.p10k.zsh"

        # ---- Run fastfetch once, after prompt is ready ----
        autoload -Uz add-zsh-hook
        _run_fastfetch_once() {
          add-zsh-hook -d precmd _run_fastfetch_once
          command -v fastfetch >/dev/null && command fastfetch --pipe false
        }
        add-zsh-hook precmd _run_fastfetch_once
      '')
    ];

    shellAliases = {
      # cat = "bat";
      g = "git";
      gs = "git status";
      l = "eza -lah --git-repos --header --icons";
      ll = "eza -lao --git-repos --header --icons";
      ls = "eza -lao --git-repos --header --icons";
      vim = "nvim";
      z = "zoxide";
    };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either:
  #  – `~/.nix-profile/etc/profile.d/hm-session-vars.sh`
  #  – `~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh`
  #  – `/etc/profiles/per-user/<username>/etc/profile.d/hm-session-vars.sh`
  home.sessionVariables = {
    # COLORTERM = "truecolor";
    EDITOR = "nvim";
    # INSTALL_OLLAMA_MODELS = 1;
    # OLLAMA_MODELS = "deepseek-r1:14b devstral-2 devstral-small-2 gpt-oss llama3.1:8b qwen3-coder:30b qwen2.5-coder:7b nishtahir/zeta lennyerik/zeta";
    # -- Best for refactors + codegen: qwen2.5-coder:latest/qwen2.5-coder:7b
    # -- Fast “autocomplete-like” coding helper: starcoder2:3b (or :7b)
    # -- General chat / planning / explaining code: llama3.1:latest/llama3.1:8b
  };

  # Aliases
  home.shellAliases = {
    b2 = "backblaze-b2";
    # code = "code-insiders";
    code = "zed";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Provide p10k instant prompt cache location
  xdg.enable = true;

  # Manage Ghostty config
  xdg.configFile."ghostty/config".source = ../xdg/ghostty/config;

  # Manage nano config (prefer XDG path on macOS/Linux)
  xdg.configFile."nano/nanorc".text = ''
    ## Load all syntax definitions that come with nano in nixpkgs
    include ${pkgs.nano}/share/nano/*.nanorc

    ## Nice defaults
    set linenumbers
    set mouse
    set tabsize 2
    set tabstospaces
    set softwrap
    set indicator
    # set constantshow
  '';

  # xdg.configFile."ghostty/themes/One Dark".text = ''
  #   # One Dark theme for Ghostty
  #   palette = 0=#1e2127
  #   palette = 1=#e06c75
  #   palette = 2=#98c379
  #   palette = 3=#d19a66
  #   palette = 4=#61afef
  #   palette = 5=#c678dd
  #   palette = 6=#56b6c2
  #   palette = 7=#abb2bf
  #   palette = 8=#5c6370
  #   palette = 9=#e06c75
  #   palette = 10=#98c379
  #   palette = 11=#d19a66
  #   palette = 12=#61afef
  #   palette = 13=#c678dd
  #   palette = 14=#56b6c2
  #   palette = 15=#ffffff
  #   background = #1e2127
  #   foreground = #abb2bf
  # '';

  # Ghostty: install One Dark theme into the custom themes dir
  xdg.configFile."ghostty/themes/One Dark".source = "${ghosttyOneDark}/One Dark";

  # Optional: manage Ghostty config too (only do this if you want HM owning the whole file)
  # xdg.configFile."ghostty/config".text = ''
  #   theme = "One Dark"
  # '';

  # Make p10k fully declarative under Home-Manager
  xdg.configFile."zsh/.p10k.zsh".source = ../xdg/zsh/.p10k.zsh;

  # xdg.configFile."zsh/zshrc.d/70-openai.zsh".source = ../xdg/zsh/zshrc.d/70-openai.zsh;
  xdg.configFile."zsh/zshrc.d/90-local.zsh".source = ../xdg/zsh/zshrc.d/90-local.zsh;
}
