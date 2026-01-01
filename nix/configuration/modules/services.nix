{ config, pkgs, lib, username, ... }: {
  services = {
    greetd = {
      enable = true;
      restart = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet -t -r --remember-session";
          user = "greeter";
        };
      };
    };
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

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "null";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };
}
