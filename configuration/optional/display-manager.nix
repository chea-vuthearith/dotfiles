{...}: {
  services.displayManager = {
    enable = true;
    ly = {
      enable = true;
      settings = {
        hide_version_string = true;
        hide_key_hints = true;
        hide_borders = true;
      };
    };
  };
}
