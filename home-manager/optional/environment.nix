{...}: {
  home = {
    stateVersion = "24.11";
    preferXdgDirectories = true;
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      NIXPKGS_ALLOW_UNFREE = 1;
      XCURSOR_THEME = "Catppuccin-Mocha-Lavender-Cursors";
      XCURSOR_SIZE = "12";
    };
  };
}
