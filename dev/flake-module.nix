{ config, lib, inputs, ... }:

{
  imports = [
    inputs.pre-commit-hooks-nix.flakeModule
  ];
  systems = [ "x86_64-linux" "aarch64-darwin" ];

  perSystem = { config, pkgs, ... }: {

    devShells.default = pkgs.mkShell {
      nativeBuildInputs = [
        pkgs.nixpkgs-fmt
      ];
      shellHook = ''
        ${config.pre-commit.shellHook}
      '';
    };

    pre-commit = {
      inherit pkgs; # should make this default to the one it can get via follows
      settings = {
        hooks.nixpkgs-fmt.enable = true;
      };
    };

  };
  flake = {
    # for repl exploration / debug
    config.config = config;
    options.mySystem = lib.mkOption { default = config.allSystems.${builtins.currentSystem}; };
  };
}
