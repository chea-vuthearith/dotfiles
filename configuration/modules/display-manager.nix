{config, ...}: {
  services.displayManager = {
    enable = true;
    ly = {
      enable = true;
      settings = with config.lib.stylix.colors; {
        fg = "0xFF${base05}";
        error_fg = "0xFF${base08}";
        hide_version_string = true;
        hide_key_hints = true;
        hide_borders = true;
      };
    };
  };
}
