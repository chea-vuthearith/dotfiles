{config, ...}: let
  inherit (config) username;
in {
  flake.modules.nixos.desktop = {...}: {
    users.users.${username}.extraGroups = [
      "input"
      "dialout"
      "kvm"
    ];
  };
}
