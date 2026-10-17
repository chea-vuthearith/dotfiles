{...}: {
  flake.modules.nixos.host-server = {...}: {
    services.logind.settings.Login.HandlePowerKey = "ignore";
    boot.loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
      };
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
  };
}
