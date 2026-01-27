# First run: `nix run github:nix-community/home-manager -- switch --flake .#default --impure`
# Subsequent runs: `home-manager switch --flake .#default --impure`
{
  description = "My Home Manager configuration";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Ghossty "One Dark" theme repo
    ghosttyOneDark = {
      url = "github:avesst/ghostty-onedark";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, home-manager, ghosttyOneDark, ... }:
    let
      # Use the host system automatically (e.g. aarch64-darwin, x86_64-darwin, x86_64-linux, aarch64-linux)
      system = "aarch64-darwin";

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];

        config = {
          allowUnfreePredicate = pkg:
            builtins.elem (nixpkgs.lib.getName pkg) [
              "claude-code"
              # "orbstack"
            ];
        };
      };

      # Pull from the environment so we don't hardcode it.
      # NOTE: requires `--impure` when evaluating the flake.
      username =
        let u = builtins.getEnv "USER";
        in if u != "" then u else "kyleaffolder";
    in
    {
      overlays.default = import ./nix/overlays/default.nix;

      # Optional: also expose the package directly from the flake
      packages.${system}.bbrew = pkgs.bbrew;

      # Nix flake checks (so CI can just run `nix flake check`)
      checks.${system} = {
        # Ensure the custom package builds
        bbrew = self.packages.${system}.bbrew;

        # Ensure the full Home Manager activation package builds
        home = self.homeConfigurations.default.activationPackage;
      };

      # devShell is cleaner for “update scripts + maintenance tooling” (and makes CI/local runs more consistent).
      # can be ran with `nix develop -c ./scripts/update-bbrew.sh`
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          curl
          jq
          nix-prefetch-github
          git
        ];
      };

      # Use a stable output name (so it doesn't depend on username.)
      homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./nix/home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = { inherit username ghosttyOneDark; };
      };
    };
}
