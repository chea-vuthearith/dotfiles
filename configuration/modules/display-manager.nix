{pkgs, ...}: {
  displayManager = {
    enable = true;
    ly = {
      enable = true;
      settings = {
        text_in_center = true;
        hide_version_string = true;
        hide_key_hints = true;
        hide_borders = true;
      };
    };
  };
}
