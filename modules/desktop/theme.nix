{inputs, ...}: {
  flake.modules.nixos.desktop = {pkgs, ...}: {
    nixpkgs.overlays = [
      (final: prev: {
        tela-circle-icon-theme = prev.tela-circle-icon-theme.overrideAttrs (_: {
          src = prev.fetchFromGitHub {
            owner = "vinceliuice";
            repo = "tela-circle-icon-theme";
            rev = "bdb616e4cb0cf61fc6bd52a42af9c07261015b21";
            sha256 = "sha256-3vqFK+yyk3EJwEpeKY92CHpFKLbXWDu1W3IDGl93VDo=";
          };
        });
        inherit (inputs.apple-fonts.packages.${final.stdenv.hostPlatform.system}) sf-pro-nerd;
      })
    ];
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans
    ];
    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      targets = {
        nixos-icons.enable = true;
        plymouth = {
          logoAnimated = false;
          colors.override = {
            base00-dec-r = "0";
            base00-dec-g = "0";
            base00-dec-b = "0";
          };
        };
        console.colors.override.base00-hex = "000000";
        grub = {
          enable = false;
          useWallpaper = false;
        };
      };
    };
  };
  flake.modules.homeManager.desktop = {
    config,
    osConfig,
    pkgs,
    ...
  }: {
    home = {
      sessionVariables = {
        XCURSOR_THEME = "Catppuccin-Mocha-Lavender-Cursors";
        XCURSOR_SIZE = "12";
      };
      packages = with pkgs; [
        pkgs.sf-pro-nerd
        nerd-fonts.fira-code
      ];
    };

    stylix = {
      opacity.terminal = 0.9;
      image = ../../wallpapers/waterfall.jpg;
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
        ghostty.fonts.enable = false; # self managed
        rofi.enable = false; # unused; stylix still sets the renamed programs.rofi.font
        hyprland.hyprpaper.enable = false; # managed by dms;
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
  };
}
