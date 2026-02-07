{pkgs, ...}: {
  home.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.victor-mono
  ];

  stylix = {
    image = ../../wallpapers/red-nebulae.jpg;
    enable = true;
    fonts = {
      sizes = {
        popups = 12;
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };

      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };

      monospace = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font";
      };

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };

    targets = {
      wezterm.colors.override.base00 = "#000000";
      hyprland.hyprpaper.enable = false; # managed by caelestia;
      hyprlock.image.enable = false;
      neovide.fonts.enable = false;
      neovim.enable = false;
      fuzzel = {
        colors.override = {
          base0D-hex = "#000000";
        };
      };
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 12;
    };
  };

  gtk.enable = true;
  qt.enable = true;
}
