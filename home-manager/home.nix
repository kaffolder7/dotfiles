# Run with `home-manager switch --flake .#default --impure`
{ config, pkgs, lib, username, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory =
    if pkgs.stdenv.isDarwin
    then "/Users/${username}"
    else "/home/${username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # Backblaze B2
    # Command-line tool for accessing the Backblaze B2 storage service
    pkgs.backblaze-b2

    # Bat is a better `cat`.
    # Get syntax highlighting, line numbers, and Git integration.
    pkgs.bat

    # Codex CLI
    # Lightweight coding agent that runs in your terminal
    pkgs.codex

    # Eza is a better `ls`.
    # Get colors, icons, tree views, Git status.
    pkgs.eza

    # FastFetch
    # Fetches system information and displays it in a visually appealing way.
    pkgs.fastfetch

    # Provides `telnet`
    # pkgs.inetutils

    # LLM
    # Access large language models from the command-line
    # pkgs.(llm.withPlugins [ ])
    pkgs.llm
    # pkgs.llm.withPlugins [ ... ]
    # (pkgs.llm.withPlugins [ /* plugin derivations here */ ])

    # Neovim
    # Vim-fork focused on extensibility and usability
    pkgs.neovim

    pkgs.curl
    pkgs.jq
    pkgs.nano
    pkgs.repomix
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
        # ---- Output-producing stuff MUST be above instant prompt ----

        # (Optional) If you were forcing TERM later, do NOT do that.
        # Let your terminal set TERM. If you need truecolor hints:
        # export COLORTERM="''${COLORTERM:-truecolor}"

        # # Run fastfetch once, only in interactive shells
        # if [[ -o interactive ]] && command -v fastfetch >/dev/null; then
        #   if [[ -z "''${__FASTFETCH_RAN-}" ]]; then
        #     __FASTFETCH_RAN=1
        #     fastfetch
        #   fi
        # fi

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
        mkdir -p "$XDG_CACHE_HOME/zsh"
        export ZSH_COMPDUMP="$XDG_CACHE_HOME/zcompdump-$ZSH_VERSION"

        # Completion caching helps a lot (set styles before compinit)
        zstyle ':completion:*' use-cache on
        zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
        zstyle ':completion:*' rehash true  # Reduce completion chattiness/overhead a bit

        # Helps with menu selection / nicer completion lists
        # zmodload zsh/complist 2>/dev/null
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
        # Fast completion init: compile once, reuse cache
        # autoload -Uz compinit
        # compinit -C -d "$ZSH_COMPDUMP"

        # alias -- code=code-insiders
        # alias -- gs='git status'
        # alias -- vim=nvim

        # ---- Minimal, fast aliases (optional) ----
        # alias ll='ls -lah'
        # alias g='git'

        # ---- Prompt (P10k) ----
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

        # ---- Run fastfetch once, after prompt is ready ----
        autoload -Uz add-zsh-hook
        _run_fastfetch_once() {
          add-zsh-hook -d precmd _run_fastfetch_once
          command -v fastfetch >/dev/null && command fastfetch --pipe false
        }
        add-zsh-hook precmd _run_fastfetch_once

        # ---- Ghostty nicety (optional) ----
        # IMPORTANT: avoid forcing TERM here (it can break color detection/themes)
        # export TERM=xterm-256color
      '')
    ];

    shellAliases = {
      g = "git";
      gs = "git status";
      ll = "eza -lao --git-repos --header --icons";
      ls = "eza -lao --git-repos --header --icons";
      vim = "nvim";
    };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/<username>/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # COLORTERM = "truecolor";
    EDITOR = "neovim";
  };

  # Aliases
  home.shellAliases = {
    code = "code-insiders";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Provide p10k instant prompt cache location
  xdg.enable = true;

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

  xdg.configFile."zsh/zshrc.d/70-openai.zsh".source = ../zsh/zshrc.d/70-openai.zsh;
  xdg.configFile."zsh/zshrc.d/90-local.zsh".source = ../zsh/zshrc.d/90-local.zsh;
  # xdg.configFile."zsh/zshrc.d/90-local.zsh".source =
  # config.lib.file.mkOutOfStoreSymlink
  #   "${config.home.homeDirectory}/path/to/90-local.zsh";
}
