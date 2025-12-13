{ inputs, config, pkgs, ... }:

{
  imports = [
    ../../../configuration/modules/no-rgb.nix
    ../../../configuration/modules/rocm.nix
    ./overrides/hardware.nix
    ./overrides/services.nix
    ./overrides/hibernate.nix
    ./overrides/keyboard.nix
  ];
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = { kuro = import ../home-manager/home.nix; };
  };
}
