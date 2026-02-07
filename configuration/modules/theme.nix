{pkgs, ...}: {
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    targets = {
      nixos-icons.enable = true;
      chromium.enable = false; # inherit theme from gtk
      plymouth = {
        logoAnimated = false;
        colors.override = {
          base00-dec-r = "0";
          base00-dec-g = "0";
          base00-dec-b = "0";
        };
      };
      console.colors.override.base00-hex = "000000";
      limine = {
        image.enable = false;
        colors.override.base00 = "#000000";
      };
    };
  };
}
