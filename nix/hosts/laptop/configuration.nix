{ inputs, config, pkgs, ... }:

{
  imports = [ ../../configuration.nix ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = { kuro = import ./home.nix; };
  };
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
      settings = { General = { Experimental = true; }; };
    };
  };

  services = {
    upower.enable = true;
    thermald.enable = true;
    tlp = {
      enable = true;
      settings = {
        STOP_CHARGE_THRESH_BAT0 = 80;

      };
    };
  };

}

