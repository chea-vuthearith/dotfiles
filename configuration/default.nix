{
  inputs,
  lib,
  ...
}: {
  imports =
    [
      inputs.home-manager.nixosModules.default
      inputs.nixos-hardware.nixosModules.common-gpu-intel
      inputs.stylix.nixosModules.stylix
    ]
    ++ lib.collectModules ./modules ++ [/etc/nixos/hardware-configuration.nix];
}
