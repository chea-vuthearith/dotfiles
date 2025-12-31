{ config, pkgs, lib, username, ... }: {
  services = {
    aria2 = {
      enable = true;
      settings = {
        enable-rpc = true;
        resume = true;
        dir = "/home/${username}/Downloads";
      };
      rpcSecretFile = "/home/${username}/.aria2secret";
    };
    logind.settings.Login.HandlePowerKey = "ignore";
    openssh.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
    displayManager = {
      enable = true;
      ly = {
        enable = true;
        settings = {
          text_in_center = true;
          hide_version_string = true;
          hide_key_hints = true;
          hide_borders = true;
        };
      };
    };
  };
  virtualisation = {
    spiceUSBRedirection.enable = true;
    docker = {
      extraPackages = [ pkgs.docker-buildx ];
      enable = true;
      enableOnBoot = false;
    };
  };
  security.polkit.enable = true;
}
