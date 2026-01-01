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
