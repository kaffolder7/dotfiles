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
      # Use the host system automatically (e.g. aarch64-darwin, x86_64-darwin, x86_64-linux, aarch64-linux)
      system = builtins.currentSystem;

      # pkgs = nixpkgs.legacyPackages.${system};
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      };

      # Pull from the environment so we don't hardcode it.
      # NOTE: requires `--impure` when evaluating the flake.
      username = builtins.getEnv "USER";
    in
    {
      overlays.default = import ./nix/overlays/default.nix;

      # Optional: also expose the package directly from the flake
      # packages.${system}.bbrew =
      #   let pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
      #   in pkgs.bbrew;
      packages.${system}.bbrew = pkgs.bbrew;

      # Use a stable output name (so it doesn't depend on username.)
      homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./nix/home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = { inherit username; };
      };
    };
}