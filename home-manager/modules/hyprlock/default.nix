{
  pkgs,
  config,
  lib,
  ...
}: {
  programs.hyprlock = {
    enable = true;
    settings = {
      input-field = {
        monitor = "";
        size = "250, 50";
        outline_thickness = 2;
        dots_size = 0.1;
        dots_spacing = 0.3;
        fade_on_empty = true;
        position = "0, 20";
        halign = "center";
        valign = "center";
      };
      background = {
        path = "screenshot";
        blur_size = 10;
        blur_passes = 3;
      };
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };
    };
  };
}
