{
  config,
  pkgs,
  ...
}: {
  services = {
    cliphist.enable = true;
    hyprpolkitagent.enable = true;
    hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };
        listener = [
          {
            timeout = 3 * 60;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 5 * 60;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 10 * 60;
            on-timeout = "systemctl suspend-then-hibernate";
          }
        ];
      };
    };
    gammastep = {
      enable = true;
      longitude = "104.888535";
      latitude = "11.562108";
    };
  };
}
