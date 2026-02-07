{pkgs, ...}: {
  stylix = {
    enable = true;
    image = ../../wallpapers/red-nebulae.jpg;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    targets = {
      chromium.enable = false;
      plymouth = {
        logoAnimated = false;
        colors.override = {
          base00-dec-r = "0";
          base00-dec-g = "0";
          base00-dec-b = "0";
        };
      };
      console.colors.override.base00-hex = "000000";
      limine.colors.override.base00 = "#000000";
    };
  };
}
