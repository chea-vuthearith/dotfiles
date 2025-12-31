{ inputs, config, pkgs, username, ... }:

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
    users = { ${username} = import ../home-manager/home.nix; };
  };
}
