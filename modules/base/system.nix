{...}: {
  flake.modules.nixos.base = {...}: {
    # Timezone follows location (geoclue), so it changes when travelling.
    services.automatic-timezoned.enable = true;
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
