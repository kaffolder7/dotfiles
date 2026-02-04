# =============================================================================
# Home Manager Configuration
# =============================================================================
#
# Run (if `home-manager` is on `PATH`):
#   home-manager switch --flake .#macmini
#   home-manager switch --flake .#mbp
#
# Or via nix run:
#   nix run github:nix-community/home-manager -- switch --flake .#macmini
#
{
  pkgs,
  lib,
  config,
  username,
  ghosttyOneDark,
  hostName,
  ...
}:

{
  # ===========================================================================
  # Core Configuration
  # ===========================================================================

  home.username = username;
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  # https://home-manager-options.extranix.com/?query=stateVersion
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Enable XDG base directories (provide p10k instant prompt cache location)
  xdg.enable = true;

  # ===========================================================================
  # Environment Variables
  # ===========================================================================

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
    # EDITOR = "nvim";
    EDITOR = lib.mkDefault "nvim";
    # Uncomment to enable Ollama model installation during setup
    # INSTALL_OLLAMA_MODELS = "1";
    # OLLAMA_MODELS = "gemma3 llama3.1:8b qwen2.5-coder:7b";
    #
    # Available models:
    # OLLAMA_MODELS = "deepseek-r1:14b devstral-2 devstral-small-2 gpt-oss llama3.1:8b qwen3-coder:30b qwen2.5-coder:7b nishtahir/zeta lennyerik/zeta";
    # -- Best for refactors + codegen: qwen2.5-coder:latest/qwen2.5-coder:7b
    # -- Fast “autocomplete-like” coding helper: starcoder2:3b (or :7b)
    # -- General chat / planning / explaining code: llama3.1:latest/llama3.1:8b
  };

  # ===========================================================================
  # Shell Aliases (global, available in all shells)
  # ===========================================================================

  home.shellAliases = {
    b2 = "backblaze-b2";
    # code = "code-insiders";
    code = "zed";
  };

  # ===========================================================================
  # Programs with Dedicated Home Manager Modules
  # ===========================================================================
  # These provide shell integration, configuration options, and type safety.
  # Prefer these over raw home.packages when available.
  #
  # All available programs/configs can be found here: https://nix-community.github.io/home-manager/options.xhtml

  # ---------------------------------------------------------------------------
  # Atuin - Magical shell history
  # ---------------------------------------------------------------------------
  # programs.atuin = {
  #   enable = true;
  #   # enableZshIntegration = true;
  # };

  # ---------------------------------------------------------------------------
  # Bat - A better `cat` with syntax highlighting
  # ---------------------------------------------------------------------------
  programs.bat = {
    enable = true;
    config = {
      theme = "OneHalfDark";
      pager = "less -FR";
      style = "numbers,changes,header";
    };
  };

  # ---------------------------------------------------------------------------
  # broot - A new way to see and navigate directory trees
  # ---------------------------------------------------------------------------
  # programs.broot = {
  #   enable = true;
  #   enableZshIntegration = true;
  # };

  # ---------------------------------------------------------------------------
  # Claude Code - An agentic coding tool
  # ---------------------------------------------------------------------------
  programs.claude-code = {
    enable = true;
  };

  # ---------------------------------------------------------------------------
  # Codex - Lightweight coding agent
  # ---------------------------------------------------------------------------
  programs.codex = {
    enable = true;
  };

  # ---------------------------------------------------------------------------
  # Direnv - Automatic environment switching
  # ---------------------------------------------------------------------------
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true; # Faster nix-shell/devShell caching
    config = {
      global = {
        warn_timeout = "30s";
        hide_env_diff = true;
      };
    };
  };

  # ---------------------------------------------------------------------------
  # Docker - Pack, ship and run any application as a lightweight container
  # ---------------------------------------------------------------------------
  programs.docker-cli = {
    enable = true;
  };

  # ---------------------------------------------------------------------------
  # Eza - A modern replacement for `ls`
  # ---------------------------------------------------------------------------
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
    extraOptions = [
      "--git-repos"
      "--group-directories-first"
      "--header"
    ];
  };

  # ---------------------------------------------------------------------------
  # fastfetch - System info display
  # ---------------------------------------------------------------------------
  programs.fastfetch = {
    enable = true;
  };

  # ---------------------------------------------------------------------------
  # fd - A fast alternative to `find`
  # ---------------------------------------------------------------------------
  programs.fd = {
    enable = true;
    hidden = true;
    ignores = [
      ".git/"
      "node_modules/"
      ".direnv/"
    ];
  };

  # ---------------------------------------------------------------------------
  # fzf - Fuzzy finder
  # ---------------------------------------------------------------------------
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
    ];
  };

  # ---------------------------------------------------------------------------
  # Git - Version control
  # ---------------------------------------------------------------------------
  programs.git = {
    enable = true;
    lfs.enable = true; # Git extension for versioning large files

    # Default config (can be overridden in ~/.gitconfig.local)
    settings = {
      init.defaultBranch = "main";
      core.editor = "nvim";
      # core.editor = "nano";
      push.autoSetupRemote = true;
      pull.rebase = false;

      # User settings
      # user.name = "Kyle Affolder"; # Can be overridden in host-specific modules
      # user.email = "kyleaffolder@gmail.com";

      # Better diffs
      diff.algorithm = "histogram";
      diff.colorMoved = "default";

      # Safer operations
      merge.conflictStyle = "zdiff3";
      rebase.autoStash = true;
    };

    # Include local config for user-specific settings (name, email, signing)
    includes = [
      { path = "~/.gitconfig.local"; }
    ];
  };

  # ---------------------------------------------------------------------------
  # GitHub CLI
  # ---------------------------------------------------------------------------
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      git_protocol = "https";
      prompt = "enabled";
    };
  };

  # ---------------------------------------------------------------------------
  # gnupg - Modern release of the GNU Privacy Guard, a GPL OpenPGP implementation
  # ---------------------------------------------------------------------------
  # programs.gpg = {
  #   enable = true;
  # };

  # ---------------------------------------------------------------------------
  # helix - Post-modern modal text editor
  # ---------------------------------------------------------------------------
  # programs.helix = {
  #   enable = true;
  # };

  # ---------------------------------------------------------------------------
  # jq - JSON processor
  # ---------------------------------------------------------------------------
  programs.jq.enable = true;

  # ---------------------------------------------------------------------------
  # Neovim - Text editor
  # ---------------------------------------------------------------------------
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

  # ---------------------------------------------------------------------------
  # OpenCode - AI coding agent built for the terminal
  # ---------------------------------------------------------------------------
  # programs.opencode = {
  #   enable = true;
  # };

  # ---------------------------------------------------------------------------
  # Pandoc - Conversion between documentation formats
  # ---------------------------------------------------------------------------
  # programs.pandoc = {
  #   enable = true;
  # };

  # ---------------------------------------------------------------------------
  # Pyenv - Simple Python version management
  # ---------------------------------------------------------------------------
  # programs.pyenv = {
  #   enable = true;
  # };

  # ---------------------------------------------------------------------------
  # Ripgrep - Fast grep alternative
  # ---------------------------------------------------------------------------
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--smart-case"
      "--hidden"
      "--glob=!.git/*"
    ];
  };

  # ---------------------------------------------------------------------------
  # Tmux - Terminal multiplexer
  # ---------------------------------------------------------------------------
  # programs.tmux = {
  #   enable = true;
  # };

  # ---------------------------------------------------------------------------
  # uv - Extremely fast Python package installer and resolver, written in Rust
  # ---------------------------------------------------------------------------
  # programs.uv = {
  #   enable = true;
  # };

  # ---------------------------------------------------------------------------
  # Zed - High-performance, multiplayer code editor from the creators of Atom and Tree-sitter
  # ---------------------------------------------------------------------------
  programs.zed-editor = {
    enable = true;
    extraPackages = [
      pkgs.nil # Yet another language server for Nix (necessary for Zed editor?)
      pkgs.nixd # Feature-rich Nix language server interoperating with C++ nix (necessary for Zed editor?)
    ];
  };

  # ---------------------------------------------------------------------------
  # yt-dlp - Feature-rich command-line audio/video downloader
  # ---------------------------------------------------------------------------
  # programs.yt-dlp = {
  #   enable = true;
  # };

  # ---------------------------------------------------------------------------
  # Zoxide - Smarter `cd` command
  # ---------------------------------------------------------------------------
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ]; # Replace cd with zoxide
  };

  # ===========================================================================
  # Zsh Configuration
  # ===========================================================================

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;

    # History configuration (XDG-compliant)
    history = {
      size = 10000;
      save = 10000;
      path = "${config.xdg.stateHome}/zsh/history";
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
      share = true;
    };

    # Session variables specific to Zsh
    sessionVariables = {
      # Ensure XDG dirs are set early
      XDG_CACHE_HOME = "${config.xdg.cacheHome}";
      XDG_CONFIG_HOME = "${config.xdg.configHome}";
      XDG_STATE_HOME = "${config.xdg.stateHome}";

      # Completion dump location
      ZSH_COMPDUMP = "${config.xdg.cacheHome}/zsh/zcompdump-$ZSH_VERSION";

      # Indicate we're using Home Manager route
      DOTFILES_ROUTE = "hm";
    };

    # Shell aliases (Zsh-specific, supplements home.shellAliases)
    shellAliases = {
      g = "git";
      gs = "git status";
      gd = "git diff";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gco = "git checkout";
      gb = "git branch";
      glog = "git log --oneline --graph --decorate";

      # Eza aliases (supplements programs.eza integration)
      # Note: programs.eza.extraOptions only apply to bare `eza` calls,
      # so we include the flags explicitly here for consistency
      l = "eza -lah --icons --git --git-repos --header";
      ll = "eza -lao --icons --git --git-repos --header";
      la = "eza -la --icons --git --git-repos --header";
      lt = "eza --tree --level=2 --icons";

      # Quick navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Safety aliases
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";

      # Misc
      reload = "exec zsh";
      path = "echo $PATH | tr ':' '\\n'";
    };

    # Zsh initialization content using mkMerge for ordering
    initContent = lib.mkMerge [
      # 500: Very early - output-producing stuff MUST be before instant prompt
      (lib.mkOrder 500 ''
        # ---- Output-producing stuff MUST be above instant prompt ----

        # Only show fastfetch in Ghostty (avoid ssh, tmux, etc.)
        if [[ -o interactive ]] && [[ "''${TERM_PROGRAM-}" == "ghostty" ]]; then
          command -v fastfetch >/dev/null && fastfetch --pipe false
        fi

        # Powerlevel10k instant prompt (must be near the top)
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi

        # Interactive-only from here down
        [[ -o interactive ]] || return
      '')

      # 550: Before completion init - set up completion styles
      (lib.mkOrder 550 ''
        # ---- Performance knobs ----
        mkdir -p "''${XDG_CACHE_HOME}/zsh" "''${XDG_CACHE_HOME}/zsh/zcompcache"

        # Completion caching (set styles before compinit)
        zstyle ':completion:*' use-cache on
        zstyle ':completion:*' cache-path "''${XDG_CACHE_HOME}/zsh/zcompcache"
        zstyle ':completion:*' rehash true

        # Better completion UI
        zstyle ':completion:*' menu select
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case-insensitive
        zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

        # Load complist for menu selection
        zmodload zsh/complist 2>/dev/null || true
      '')

      # 1000: General init - source modular config files
      (lib.mkOrder 1000 ''
        # ---- Source modular zsh config ----
        local ZSHRC_DIR="''${XDG_CONFIG_HOME}/zsh/zshrc.d"
        if [[ -d "$ZSHRC_DIR" ]]; then
          for f in "$ZSHRC_DIR"/*.zsh(N); do
            source "$f"
          done
        fi
        unset f
      '')

      # 1500: Late init - prompt and final setup
      (lib.mkOrder 1500 ''
        # ---- Prompt (Powerlevel10k) ----

        # Disable the p10k wizard - we have a managed config
        typeset -g POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

        # Load Powerlevel10k theme
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

        # Load p10k config
        [[ -r "''${ZDOTDIR:-$HOME}/.p10k.zsh" ]] && source "''${ZDOTDIR:-$HOME}/.p10k.zsh"

        # ---- Final touches ----

        # Unique arrays (no duplicates in PATH, etc.)
        typeset -U path cdpath fpath manpath
      '')
    ];
  };

  # ===========================================================================
  # Packages (things without dedicated HM modules)
  # ===========================================================================
  # The home.packages option allows you to install Nix packages into your
  # environment.

  home.packages = with pkgs; [
    # -------------------------------------------------------------------------
    # Cloud & Backup
    # -------------------------------------------------------------------------
    backblaze-b2 # B2 Cloud Storage CLI

    # -------------------------------------------------------------------------
    # Development Tools
    # -------------------------------------------------------------------------
    bbrew # TUI for managing Homebrew packages
    claude-code # Anthropic's coding assistant
    codex # OpenAI's coding agent
    curl # HTTP client
    ddev # Docker-based PHP/Node.js development
    mkcert # Local HTTPS certificates
    nss # Required for mkcert

    # -------------------------------------------------------------------------
    # Optional VS Code extensions (uncomment if using VS Code as your IDE)
    # -------------------------------------------------------------------------
    # vscode-extensions.alefragnani.bookmarks
    # vscode-extensions.anthropic.claude-code
    # vscode-extensions.bbenoist.nix
    # vscode-extensions.dbaeumer.vscode-eslint
    # vscode-extensions.editorconfig.editorconfig
    # vscode-extensions.esbenp.prettier-vscode
    # vscode-extensions.github.vscode-github-actions
    # vscode-extensions.jgclark.vscode-todo-highlight
    # vscode-extensions.mechatroner.rainbow-csv
    # vscode-extensions.mikestead.dotenv
    # vscode-extensions.ms-python.debugpy
    # vscode-extensions.ms-python.python
    # vscode-extensions.ms-python.vscode-pylance
    # vscode-extensions.ms-vscode-remote.vscode-remote-extensionpack
    # vscode-extensions.teabyii.ayu

    # -------------------------------------------------------------------------
    # Nix Tooling
    # -------------------------------------------------------------------------
    nil # Nix language server
    nixd # Feature-rich Nix language server
    nix-prefetch-github # Prefetch GitHub sources

    # -------------------------------------------------------------------------
    # Shell & Terminal
    # -------------------------------------------------------------------------
    nano # Simple text editor
    zsh-powerlevel10k # Prompt theme (fast reimplementation of Powerlevel9k ZSH theme)

    # -------------------------------------------------------------------------
    # File & Text Processing
    # -------------------------------------------------------------------------
    repomix # Pack repo for AI consumption
    yt-dlp # Video downloader

    # -------------------------------------------------------------------------
    # Optional packages (uncomment as needed)
    # -------------------------------------------------------------------------
    # atuin          # Shell history with sync
    # atuin-desktop  # Local-first, executable runbook editor
    # axel           # Download accelerator
    # broot          # Tree view navigator
    # claude-monitor # Real-time Claude Code usage monitor
    # colima         # Container runtimes
    # doppler        # Secrets management
    # ffmpeg         # Media processing
    # gnupg          # GPG encryption
    # helix          # Modal text editor
    # inetutils      # Provides `telnet`
    # llm            # LLM CLI tool
    # # pkgs.llm.withPlugins [ ... ]
    # # (pkgs.llm.withPlugins [ /* plugin derivations here */ ])
    # nanorc         # Improved Nano Syntax Highlighting Files
    # nodenv         # Manage multiple NodeJS versions
    # nodeenv        # Node.js virtual environment builder
    # nodejs         # Node.js runtime
    # nodejs_24      # Node.js v24 runtime (latest)
    # ollama         # Local LLM server
    # opencode       # AI coding agent
    # openllm        # Run any open-source LLMs, such as Llama 3.1, Gemma, as OpenAI compatible API endpoint in the cloud
    # orbstack       # Fast, light, and easy way to run Docker containers and Linux machines
    # pandoc         # Document converter
    # pass           # Password manager
    # pyenv          # Python version manager
    # python314      # Python runtime
    # speedtest-cli  # Internet speed test
    # stow           # Symlink manager
    # syncthing      # File sync
    # syncthing-macos # Official frugal and native macOS Syncthing application bundle
    # tmux           # Terminal multiplexer
    # uv             # Fast Python package manager
    # vllm           # High-throughput and memory-efficient inference and serving engine for LLMs
    # wget           # File downloader
  ];

  # ===========================================================================
  # Services with Dedicated Home Manager Modules
  # ===========================================================================
  # These provide shell integration, configuration options, and type safety.

  # ---------------------------------------------------------------------------
  # Ollama - Get up and running with large language models locally
  # ---------------------------------------------------------------------------
  # services.ollama = {
  #   enable = true;
  # };

  # ---------------------------------------------------------------------------
  # Syncthing - Open Source Continuous File Synchronization
  # ---------------------------------------------------------------------------
  # services.syncthing = {
  #   enable = true;
  # };

  # ===========================================================================
  # XDG Config Files
  # ===========================================================================

  # ---------------------------------------------------------------------------
  # Dotfiles CLI tools
  # ---------------------------------------------------------------------------
  home.file.".local/bin/dot" = {
    source = ../bin/dot;
    executable = true;
  };

  home.file.".local/bin/dot-doctor" = {
    source = ../bin/dot-doctor;
    executable = true;
  };

  # ---------------------------------------------------------------------------
  # Ghostty Terminal
  # ---------------------------------------------------------------------------
  xdg.configFile."ghostty/config".source = ../xdg/ghostty/config;
  # Optional: manage Ghostty config too (only do this if you want HM owning the whole file)
  # xdg.configFile."ghostty/config".text = ''
  #   theme = "One Dark"
  # '';

  # Install One Dark theme for Ghostty
  xdg.configFile."ghostty/themes/One Dark".source = "${ghosttyOneDark}/One Dark";
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

  # ---------------------------------------------------------------------------
  # Nano Editor
  # ---------------------------------------------------------------------------
  xdg.configFile."nano/nanorc".text = ''
    ## Load syntax definitions from nixpkgs
    include ${pkgs.nano}/share/nano/*.nanorc

    ## Editor settings
    set linenumbers
    set mouse
    set tabsize 2
    set tabstospaces
    set softwrap
    set indicator
    set autoindent
    set smarthome
  '';

  # ---------------------------------------------------------------------------
  # Powerlevel10k Config
  # ---------------------------------------------------------------------------
  xdg.configFile."zsh/.p10k.zsh".source = ../xdg/zsh/.p10k.zsh;

  # ---------------------------------------------------------------------------
  # Zsh Modular Config (for OpenAI helpers, local overrides, etc.)
  # ---------------------------------------------------------------------------
  # Note: Only include files that aren't fully handled by HM's programs.zsh
  # xdg.configFile."zsh/zshrc.d/70-openai.zsh".source = ../xdg/zsh/zshrc.d/70-openai.zsh;
  # xdg.configFile."zsh/zshrc.d/90-local.zsh".source = ../xdg/zsh/zshrc.d/90-local.zsh;

  # Symlink the entire zshrc.d directory
  xdg.configFile."zsh/zshrc.d" = {
    source = ../xdg/zsh/zshrc.d;
    recursive = true;
  };
}
