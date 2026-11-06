{...}: {
  flake.modules.homeManager.desktop = {...}: {
    services = {
      cliphist = {
        enable = true;
        systemdTargets = ["hyprland-session.target"];
      };

      hyprpolkitagent.enable = true;
    };
  };
}
