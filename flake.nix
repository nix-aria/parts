{
  description = "Flake basics described using the module system";

  inputs = {
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
  };

  outputs = inputs@{ nixpkgs-lib, ... }:
    let
      lib = import ./lib.nix {
        inherit (nixpkgs-lib) lib;
        inherit builtinModules extraModules;
        # Extra info for version check message
        revInfo =
          if nixpkgs-lib?rev
          then " (nixpkgs-lib.rev: ${nixpkgs-lib.rev})"
          else "";
      };
      builtinModules = {
        apps = ./modules/apps.nix;
        checks = ./modules/checks.nix;
        devShells = ./modules/devShells.nix;
        flake = ./modules/flake.nix;
        formatter = ./modules/formatter.nix;
        legacyPackages = ./modules/legacyPackages.nix;
        moduleWithSystem = ./modules/moduleWithSystem.nix;
        nixosConfigurations = ./modules/nixosConfigurations.nix;
        nixosModules = ./modules/nixosModules.nix;
        nixpkgs = ./modules/nixpkgs.nix;
        overlays = ./modules/overlays.nix;
        packages = ./modules/packages.nix;
        perSystem = ./modules/perSystem.nix;
        transposition = ./modules/transposition.nix;
        withSystem = ./modules/withSystem.nix;
      };
      extraModules = {
        easyOverlay = ./extras/easyOverlay.nix;
        flakeModules = ./extras/flakeModules.nix;
        modules = ./extras/modules.nix;
        partitions = ./extras/partitions.nix;
        bundlers = ./extras/bundlers.nix;
        touchup = ./extras/touchup.nix;
      };
      flakeModules = builtinModules // extraModules;
    in
    lib.mkFlake { inherit inputs; } {
      systems = [ ];
      imports = [ flakeModules.partitions ];
      partitionedAttrs.checks = "dev";
      partitionedAttrs.devShells = "dev";
      partitions.dev.extraInputsFlake = ./dev;
      partitions.dev.module = {
        imports = [ ./dev/flake-module.nix ];
      };
      flake = {
        inherit lib flakeModules;
        modules.flake = flakeModules;
      };
    };

}
