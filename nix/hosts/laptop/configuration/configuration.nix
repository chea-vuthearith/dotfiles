{ inputs, config, pkgs, ... }: {
  imports = [ ./overrides/power.nix ./overrides/hardware.nix ];
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = { kuro = import ../home-manager/home.nix; };
  };

}

