{
  config,
  pkgs,
  ...
}: {
  services = {
    cliphist.enable = true;
    hyprpolkitagent.enable = true;
    gammastep = {
      enable = true;
      longitude = "104.888535";
      latitude = "11.562108";
    };
  };
}
