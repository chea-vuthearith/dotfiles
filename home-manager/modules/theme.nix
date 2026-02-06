{pkgs, ...}: {
  home.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.victor-mono
  ];

  stylix = {
    enable = true;

    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    override.base00 = "#000000";

    polarity = "dark";

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

  # home.pointerCursor = {
  #   gtk.enable = true;
  #   package = pkgs.bibata-cursors;
  #   name = "Bibata-Modern-Classic";
  #   size = 16;
  # };
  # gtk = {
  #   enable = true;
  #   theme = {
  #     package = pkgs.gnome-themes-extra;
  #     name = "Adwaita-dark";
  #   };
  #   iconTheme = {
  #     package = pkgs.yaru-theme;
  #     name = "Yaru-purple";
  #   };
  # };
  # qt = {
  #   enable = true;
  #   platformTheme.name = "adwaita";
  #   style.name = "adwaita-dark";
  # };
}
