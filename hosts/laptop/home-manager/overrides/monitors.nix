{...}: {
  wayland.windowManager.hyprland.settings = {
    monitor = [
      {
        output = "";
        mode = "highres";
        position = "auto";
        scale = "1";
        mirror = "eDP-1";
      }
      {
        output = "eDP-1";
        mode = "1920x1200@60";
        position = "auto";
        scale = "1";
      }
    ];
  };
}
