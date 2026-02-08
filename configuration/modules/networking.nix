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

  boot = {
    # faster wifi
    kernelModules = ["tcp_bbr"];
    kernel.sysctl = {
      # network performance
      "net.core.netdev_max_backlog" = 16384;
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
  };
}
