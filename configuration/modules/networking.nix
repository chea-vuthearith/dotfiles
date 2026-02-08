{...}: {
  networking = {
    hostName = "nixos";
    networkmanager = {
      enable = true;
    };
    firewall = {
      enable = true;
    };
    wg-quick.interfaces = {
      wg0 = {
        configFile = "/etc/wireguard/wg0.conf";
        autostart = false;
      };
    };
  };

  systemd.network.wait-online.enable = false; # network dont block boot
}
