{ inputs, config, pkgs, ... }:

{
  imports = [ ../../configuration.nix ./rocm.nix ./rgb.nix ];

  hardware.graphics.enable = true;
  services = { xserver.videoDrivers = [ "modesetting" ]; };

  boot = {
    kernelModules = [ "hid_apple" ];
    kernelParams = [ "resume_offset=185636864" ];
    extraModprobeConfig = ''
      options hid_apple fnmode=2
    '';
  };

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=1h
  '';

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 24 * 1024;
  }];

  boot.resumeDevice = "/dev/nvme0n1p2";
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = { kuro = import ./home.nix; };
  };

}
