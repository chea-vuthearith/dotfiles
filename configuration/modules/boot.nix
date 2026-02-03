{
  config,
  pkgs,
  lib,
  ...
}: {
  services.logind.settings.Login.HandlePowerKey = "ignore";
  boot = {
    kernelParams = ["quiet"];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 3;
      systemd-boot.configurationLimit = 5;
    };
  };
}
