{...}: {
  flake.modules.nixos.base = {...}: {
    # Timezone follows location (geoclue), so it changes when travelling.
    services.automatic-timezoned.enable = true;
    # The NixOS geoclue module omits the [ip] source, leaving hosts without wifi
    # (desktop on ethernet) without a location and stuck on UTC. BeaconDB also
    # answers from the public IP (city-level, plenty for a timezone).
    environment.etc."geoclue/conf.d/90-ip.conf".text = ''
      [ip]
      enable=true
      method=ichnaea
    '';
    services.logind.settings.Login.HandlePowerKey = "ignore";
    system.stateVersion = "24.11";
  };
  flake.modules.homeManager.base = {...}: {
    home = {
      stateVersion = "24.11";
      preferXdgDirectories = true;
    };
  };
}
