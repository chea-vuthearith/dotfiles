{
  inputs,
  lib,
  ...
}: {
  imports =
    lib.collectModules ./modules
    ++ [
      inputs.home-manager.nixosModules.default
      /etc/nixos/hardware-configuration.nix
    ];
}
