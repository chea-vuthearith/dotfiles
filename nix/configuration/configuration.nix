{ inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.default
    /etc/nixos/hardware-configuration.nix
    ./modules/hardware.nix
    ./modules/hyprland.nix
    ./modules/boot.nix
    ./modules/networking.nix
    ./modules/users.nix
    ./modules/services.nix
    ./modules/environment.nix
  ];
}

