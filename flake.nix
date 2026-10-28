{
  description = "Nix package and NixOS module for the Composio CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    inputs@{ nixpkgs, flake-utils, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      overlay = final: _prev: {
        composio = (import ./nix/pipeline.nix { pkgs = final; }).composio;
      };
    in
    {
      overlays.default = overlay;

      nixosModules = rec {
        composio = import ./nix/module.nix;
        default = composio;
      };
    }
    // flake-utils.lib.eachSystem supportedSystems (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        pipeline = import ./nix/pipeline.nix { inherit inputs pkgs; };
      in
      rec {
        packages = {
          inherit (pipeline) composio;
          default = packages.composio;
        };

        apps = {
          composio = {
            type = "app";
            program = pkgs.lib.getExe packages.composio;
            meta.description = packages.composio.meta.description;
          };
          default = apps.composio;
        };

        devShells.default = pkgs.mkShell {
          packages = [ packages.composio ];
        };

        formatter = pkgs.nixfmt;
      }
    );
}
