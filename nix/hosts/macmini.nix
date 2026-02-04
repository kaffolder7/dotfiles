# =============================================================================
# Mac Mini Host Configuration
# =============================================================================
#
# Host-specific settings for the Mac Mini (always-on workstation/server)
#
{
  pkgs,
  lib,
  config,
  ...
}:

{
  # ===========================================================================
  # Mac Mini Specific Packages
  # ===========================================================================

  home.packages = with pkgs; [
    # Server/always-on workloads
    # ollama         # Enable if you want LLM server on the Mini

    # Sync tools (good for always-on machine)
    # syncthing      # File synchronization
  ];

  # ===========================================================================
  # Environment Variables
  # ===========================================================================

  home.sessionVariables = {
    # If running Ollama server locally
    # OLLAMA_HOST = "http://127.0.0.1:11434";

    # Machine identifier (useful for scripts)
    DOTFILES_HOST = "macmini";
  };

  # ===========================================================================
  # Host-Specific Settings
  # ===========================================================================

  # Example: Different Git config for work machine
  # programs.git.extraConfig = {
  #   user.name = "Work Name";
  #   user.email = "work@example.com";
  # };
}
