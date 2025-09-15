{ inputs, pkgs, ... }:

{
  imports = [ ../../configuration.nix ];

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
    };
  };
  virtualisation = { libvirtd.enable = true; };

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
  '';

  powerManagement.enable = true;
  services = {
    upower.enable = true;
    thermald.enable = true;
    logind = {
      settings.Login = {
        HoldoffTimeoutSec = "0s";
        HandleLidSwitch = "suspend-then-hibernate";
      };
    };
    tlp = {
      enable = true;
      settings = {
        STOP_CHARGE_THRESH_BAT0 = 80;

      };
    };
  };

}

