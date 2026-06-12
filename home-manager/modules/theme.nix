{
  config,
  osConfig,
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
    base16Scheme = osConfig.stylix.base16Scheme;
    override = {
      base0D = osConfig.lib.stylix.colors.base0E;
      base0E = osConfig.lib.stylix.colors.base0D;
    };
    polarity = "dark";
    enable = true;
    fonts = {
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
      hyprland.hyprpaper.enable = false; # managed by dms;
      neovim.enable = false;
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
  };
  qt.enable = true;
}
