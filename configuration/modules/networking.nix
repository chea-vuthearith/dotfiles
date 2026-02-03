{
  config,
  pkgs,
  lib,
  ...
}: {
  networking = {
    hosts = {"auth.localhost" = ["127.0.0.1"];};
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.enable = false;
    wg-quick.interfaces = {
      wg0 = {
        configFile = "/etc/wireguard/wg0.conf";
        autostart = false;
      };
    };
  };
  systemd.network.wait-online.enable = false;
}
