{ pkgs, ... }: {
  programs.hyprpanel.settings.bar.layouts."*" = {
    left = [ "notifications" "workspaces" ];
    middle = [ "clock" ];
    right = [
      "custom/screenRecordStatus"
      "battery"
      "systray"
      "hypridle"
      "bluetooth"
      "network"
      "volume"
    ];
  };

}
