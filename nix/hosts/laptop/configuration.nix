{ inputs, config, pkgs, ... }:

{
  imports =
    [ inputs.home-manager.nixosModules.default ../../configuration.nix ];

  environment.systemPackages = with pkgs; [ ciscoPacketTracer8 ];
  nixpkgs.config.permittedInsecurePackages =
    [ "libsoup-2.74.3" "libxml2-2.13.8" "ciscoPacketTracer8" "libxml2" ];

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
    logind = { lidSwitch = "suspend"; };
    tlp = {
      enable = true;
      settings = {
        STOP_CHARGE_THRESH_BAT0 = 80;

      };
    };
  };

}

