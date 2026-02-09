{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-pro-nerd
    nerd-fonts.fira-code
  ];

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
        package = inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-pro-nerd;
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
      wezterm.fonts.enable = false;
      opencode.colors.override.withHashtag.base00 = "#000000";
      hyprland.hyprpaper.enable = false; # managed by caelestia;
      hyprlock.image.enable = false;
      neovide.fonts.enable = false;
      neovim.enable = false;
      fuzzel = {
        fonts.override.sizes.popups = config.stylix.fonts.sizes.applications;
        opacity.override.popups = 0.9;
        colors.override = {
          base0D-hex = "#000000"; # border
          base00-hex = "#000000"; # bg
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
