{
  config,
  pkgs,
  ...
}: {
  home = {
    packages = with pkgs; [
      pkgs.sf-pro-nerd
      nerd-fonts.fira-code
    ];
  };

  stylix = {
    opacity.terminal = 0.9;
    image = ../../wallpapers/red-nebulae.jpg;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    polarity = "dark";
    enable = true;
    fonts = {
      sizes = {
        popups = 12;
      };
      serif = {
        package = pkgs.sf-pro-nerd;
        name = "SFProDisplay Nerd Font";
      };

      sansSerif = config.stylix.fonts.serif;

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
      tmux.enable = false;
      ghostty.fonts.enable = false;
      hyprland.hyprpaper.enable = false; # managed by caelestia;
      hyprlock.image.enable = false;
      neovide.fonts.enable = false;
      neovim.enable = false;
      fuzzel = {
        fonts.override.sizes.popups = config.stylix.fonts.sizes.applications;
        opacity.override.popups = 0.9;
        colors.override = {
          base0D-hex = config.lib.stylix.colors.base00-hex; # border
        };
      };
    };

    cursor = {
      package = pkgs.catppuccin-cursors.mochaLavender;
      name = "catppuccin-mocha-lavender-cursors";
      size = 12;
    };

    icons = {
      enable = true;
      package = pkgs.tela-circle-icon-theme;
      dark = "Tela-circle-dark";
    };
  };

  gtk = {
    enable = true;
    gtk4.theme = null;
  };
  qt.enable = true;
}
