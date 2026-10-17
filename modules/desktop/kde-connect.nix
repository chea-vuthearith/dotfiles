{...}: {
  flake.modules.nixos.desktop = {...}: {
    networking.firewall = rec {
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = allowedTCPPortRanges;
    };
  };
  flake.modules.homeManager.desktop = {...}: {
    services.kdeconnect = {
      enable = true;
      indicator = true;
    };
  };
}
