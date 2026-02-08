{...}: {
  networking = {
    hostName = "nixos";
    networkmanager = {
      enable = true;
      wifi.backend = "iwd"; # faster than wpa_supplicant
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

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "false";
      FallbackDNS = ["1.1.1.1" "1.0.0.1"];
    };
  };
}
