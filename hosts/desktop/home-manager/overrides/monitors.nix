{...}: {
  wayland.windowManager.hyprland.settings = {
    monitor = [
      {
        output = "";
        mode = "highres";
        position = "auto";
        scale = "1";
      }
      {
        output = "DP-1";
        mode = "2560x1440@75";
        position = "0x0";
        scale = "1";
      }
      {
        output = "DP-3";
        mode = "1920x1080@170";
        position = "2560x200";
        scale = "1";
      }
    ];
  };
}
