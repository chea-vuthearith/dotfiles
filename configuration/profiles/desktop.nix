# Graphical workstation: picks modules from ../optional.
{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.stylix.nixosModules.stylix
    ../optional/anydesk.nix
    ../optional/aria2.nix
    ../optional/boot.nix
    ../optional/display-manager.nix
    ../optional/environment.nix
    ../optional/graphics.nix
    ../optional/hyprland.nix
    ../optional/kde-connect.nix
    ../optional/nix-ld.nix
    ../optional/nixpkgs.nix
    ../optional/sound.nix
    ../optional/theme.nix
    ../optional/users.nix
    ../optional/utils.nix
    ../optional/windows.nix
  ];
}
