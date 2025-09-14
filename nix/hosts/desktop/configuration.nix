{ inputs, config, pkgs, ... }:

{
  imports = [ ../../configuration.nix ./rocm.nix ./rgb.nix ];

  hardware.graphics.enable = true;
  services = { xserver.videoDrivers = [ "modesetting" ]; };

  boot = {
    kernelModules = [ "hid_apple" ];
    extraModprobeConfig = ''
      options hid_apple fnmode=2
    '';
  };

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 34816;
  }];
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = { kuro = import ./home.nix; };
  };

}
