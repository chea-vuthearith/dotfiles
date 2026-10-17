# Builds nixosConfigurations from `hosts`. A host gets, for each name in its
# profiles plus "host-<name>", flake.modules.nixos.<name> as system modules and
# flake.modules.homeManager.<name> as home-manager modules for `username`.
{
  config,
  inputs,
  lib,
  self,
  ...
}: let
  inherit (config) username repoDir;
  inherit (config.flake) modules;

  # lib.toLocal: path inside this flake -> same path in the checkout at repoDir.
  hostLib = inputs.nixpkgs.lib.extend (_: _: {
    toLocal = path: builtins.replaceStrings [(toString self)] [repoDir] (toString path);
  });

  mkHost = name: host: let
    names = host.profiles ++ ["host-${name}"];
    pick = class: map (n: modules.${class}.${n}) (lib.filter (n: modules.${class} ? ${n}) names);
  in
    inputs.nixpkgs.lib.nixosSystem {
      lib = hostLib;
      system = "x86_64-linux";
      modules =
        pick "nixos"
        ++ [
          inputs.home-manager.nixosModules.default
          {
            networking.hostName = name;
            home-manager = {
              useUserPackages = true;
              useGlobalPkgs = true;
              users.${username}.imports = pick "homeManager";
            };
          }
        ];
    };
in {
  options.hosts = lib.mkOption {
    description = "NixOS hosts, keyed by hostname.";
    type = lib.types.attrsOf (lib.types.submodule {
      options.profiles = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "flake.modules names to import, e.g. [\"base\" \"desktop\"].";
      };
    });
  };

  config.flake.nixosConfigurations = lib.mapAttrs mkHost config.hosts;
}
