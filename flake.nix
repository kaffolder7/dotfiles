# Run with `home-manager switch --flake .#default --impure`
{
  description = "My Home Manager configuration";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, home-manager, ... }:
    let
      system = "aarch64-darwin";  # Apple Silicon; change if needed
      pkgs = nixpkgs.legacyPackages.${system};

      # Pull from the environment so we don't hardcode it.
      # NOTE: requires `--impure` when evaluating the flake.
      username = builtins.getEnv "USER";
    in
    {
      # Use a stable output name (so it doesn't depend on username.)
      homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home-manager/home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = { inherit username; };
      };
    };
}