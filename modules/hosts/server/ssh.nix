{config, ...}: let
  inherit (config) username;
in {
  flake.modules.nixos.host-server = {...}: {
    services.openssh = {
      enable = true;
      ports = [99];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        AllowUsers = [username];
        PermitRootLogin = "no";
      };
    };
    networking.firewall.allowedTCPPorts = [99];
  };
}
