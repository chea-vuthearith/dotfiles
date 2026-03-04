{
  config,
  pkgs,
  ...
}: {
  services = {
    cliphist = {
      enable = true;
      systemdTargets = ["hyprland-session.target"];
    };

    hyprpolkitagent.enable = true;
    gammastep = {
      enable = true;
      longitude = "104.888535";
      latitude = "11.562108";
    };
  };
}
