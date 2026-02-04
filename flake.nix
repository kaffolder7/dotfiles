# Initial run:
#  - `nix run github:nix-community/home-manager -- switch --flake .#macmini`, or...
#  - `nix run github:nix-community/home-manager -- switch --flake .#mbp`
{
  description = "My Home Manager configuration";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Ghostty "One Dark" theme repo
    ghosttyOneDark = {
      url = "github:avesst/ghostty-onedark";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ghosttyOneDark,
      ...
    }:
    let
      lib = nixpkgs.lib;

      # =========================================================================
      # CUSTOMIZE: Set your macOS username here
      # Run `whoami` in terminal if unsure
      # =========================================================================
      username = "kyleaffolder";

      # Use the host system automatically (e.g. aarch64-darwin, x86_64-darwin, x86_64-linux, aarch64-linux)
      supportedSystems = [ "aarch64-darwin" ];

      forAllSystems = f: lib.genAttrs supportedSystems (system: f system);

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];

          config = {
            allowUnfreePredicate =
              pkg:
              builtins.elem (nixpkgs.lib.getName pkg) [
                "claude-code"
                # "orbstack"
              ];
          };
        };

      # Helper to build a Home Manager config per host.
      mkHome =
        {
          system,
          username,
          hostName,
          hostModules ? [ ],
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;

          # Specify your home configuration modules here, for example, the path to your home.nix.
          modules = [
            ./nix/home.nix
          ]
          ++ hostModules;

          # Extra args your home.nix already expects (and a hostName you can use in modules)
          extraSpecialArgs = {
            inherit username ghosttyOneDark hostName;
          };
        };
    in
    {
      overlays.default = import ./nix/overlays/default.nix;

      # Expose your custom package(s) for each supported system
      packages = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;
        in
        {
          bbrew = pkgs.bbrew;
        }
      );

      # devShell is cleaner for “update scripts + maintenance tooling” (and makes CI/local runs more consistent).
      # can be ran with `nix develop -c ./scripts/update-bbrew.sh`
      devShells = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              curl
              jq
              nix-prefetch-github
              git
            ];
          };
        }
      );

      # Host-specific Home Manager outputs (pure; no --impure)
      homeConfigurations = {
        macmini = mkHome {
          system = "aarch64-darwin";
          # username = "kyleaffolder";
          inherit username; # Uses the variable defined above
          hostName = "macmini";
          hostModules = [ ./nix/hosts/macmini.nix ];
        };

        mbp = mkHome {
          system = "aarch64-darwin";
          # username = "kyleaffolder";
          inherit username; # Uses the variable defined above
          hostName = "mbp";
          hostModules = [ ./nix/hosts/mbp.nix ];
        };

        # Optional convenience target
        default = self.homeConfigurations.macmini;
      };

      # Nix flake checks (CI-friendly, so CI can just run `nix flake check`)
      checks = forAllSystems (system: {
        # Build custom packages
        bbrew = self.packages.${system}.bbrew;

        # Build activation packages for your darwin hosts
        home-macmini = self.homeConfigurations.macmini.activationPackage;
        home-mbp = self.homeConfigurations.mbp.activationPackage;
      });
    };
}
