{
  inputs,
  lib,
  ...
}: {
  imports =
    lib.collectModules ./modules
    ++ [
      inputs.home-manager.nixosModules.default
      # Hardware configuration is machine-specific and should be in /etc/nixos/hardware-configuration.nix
      # This import allows each machine to have its own hardware config outside the repo
      /etc/nixos/hardware-configuration.nix
    ];
}
