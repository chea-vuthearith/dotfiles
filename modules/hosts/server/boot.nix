{...}: {
  flake.modules.nixos.host-server = {...}: {
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
