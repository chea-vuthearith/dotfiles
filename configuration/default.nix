{inputs, ...}: {
  imports = [
    inputs.home-manager.nixosModules.default
    /etc/nixos/hardware-configuration.nix
    ./modules/nix-ld.nix
    ./modules/cache-host.nix
    ./modules/greetd.nix
    ./modules/hardware.nix
    ./modules/hyprland.nix
    ./modules/aria2.nix
    ./modules/sound.nix
    ./modules/boot.nix
    ./modules/networking.nix
    ./modules/users.nix
    ./modules/virtualization.nix
    ./modules/environment.nix
    ./modules/theme.nix
  ];
}
