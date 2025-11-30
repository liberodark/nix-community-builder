{
  self,
  inputs,
  lib,
  ...
}:
{
  flake =
    let
      importConfig =
        path:
        (lib.mapAttrs (name: _value: import (path + "/${name}/default.nix")) (
          lib.filterAttrs (_: v: v == "directory") (builtins.readDir path)
        ));

      allHosts = importConfig ./hosts;
      darwinHostNames = [ "build03.ynh.ovh" ];
      darwinHosts = lib.filterAttrs (name: _: lib.elem name darwinHostNames) allHosts;
      nixosHosts = lib.filterAttrs (name: _: !(lib.elem name darwinHostNames)) allHosts;
    in
    {
      nixosConfigurations = builtins.mapAttrs (
        _name: value:
        inputs.nixpkgs.lib.nixosSystem {
          inherit lib;
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [
            value
            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
          ];
          extraModules = [ inputs.colmena.nixosModules.deploymentOptions ];
        }
      ) nixosHosts;

      darwinConfigurations =
        let
          configs = builtins.mapAttrs (
            name: value:
            inputs.nix-darwin.lib.darwinSystem {
              system = "aarch64-darwin";
              specialArgs = {
                inherit inputs;
              };
              modules = [
                value
              ];
            }
          ) darwinHosts;
          # Alias: build03.ynh.ovh -> build03
          aliases = lib.mapAttrs' (
            name: value: lib.nameValuePair (builtins.head (lib.splitString "." name)) value
          ) configs;
        in
        configs // aliases;

      colmena = {
        meta = {
          nixpkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
          nodeNixpkgs = builtins.mapAttrs (_: v: v.pkgs) self.nixosConfigurations;
          nodeSpecialArgs = builtins.mapAttrs (_: v: v._module.specialArgs) self.nixosConfigurations;
          specialArgs.lib = lib;
        };
      }
      // builtins.mapAttrs (_: v: {
        deployment.tags = [ "non-critical-infra" ];
        imports = v._module.args.modules;
      }) self.nixosConfigurations;
    };

  perSystem =
    { inputs', ... }:
    let
      pkgs = inputs'.nixpkgs-unstable.legacyPackages;
    in
    {
      devShells.non-critical-infra = pkgs.mkShellNoCC {
        packages = [
          inputs'.colmena.packages.colmena
          pkgs.ssh-to-age
        ];
      };
    };
}
