# =============================================================================
# MacBook Pro Host Configuration
# =============================================================================
#
# Host-specific settings for the MacBook Pro (mobile/laptop)
#
{
  # pkgs,
  # lib,
  # config,
  ...
}:

{
  # ===========================================================================
  # MBP Specific Packages
  # ===========================================================================
  # Battery-conscious, mobile-focused

  # home.packages = with pkgs; [
  #   # Mobile-friendly tools
  #   # tailscale      # VPN for remote access to home network
  # ];

  # ===========================================================================
  # Environment Variables
  # ===========================================================================

  home.sessionVariables = {
    # Point to Mac Mini's Ollama if running remotely
    # OLLAMA_HOST = "http://macmini.local:11434";

    # Machine identifier
    DOTFILES_HOST = "mbp";

    # Maybe different editor on laptop? Overrides the default
    # EDITOR = "zed";
  };

  # ===========================================================================
  # Host-Specific Settings
  # ===========================================================================

  # Example: Battery-conscious settings could go here
  # home.sessionVariables = {
  #   # Reduce resource usage on battery
  #   HOMEBREW_NO_ANALYTICS = "1";
  # };
}
