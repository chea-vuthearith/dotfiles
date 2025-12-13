{ config, pkgs, lib, ... }: {
  networking = {
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
  systemd.services.NetworkManager-wait-online.wantedBy = lib.mkForce [ ];
}
