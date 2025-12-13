{...}: {
  programs.hyprpanel.settings.bar.layouts."*" = {
    left = [ "notifications" "workspaces" ];
    middle = [ "clock" ];
    right =
      [ "custom/screenRecordStatus" "systray" "hypridle" "network" "volume" ];
  };
}
