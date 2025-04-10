{ lib, pkgs, ... }:

{
  home.stateVersion = "24.11"; # DO NOT CHANGE
  home.username = "kuro";
  home.homeDirectory = "/home/kuro";
  home.packages = with pkgs; [

    # languages
    gcc
    lua
    pnpm_9
    python3
    luarocks
    nodejs_23

    # dev tools
    fzf
    brave
    xclip
    ripgrep
    starship
    gitAndTools.gh

    # socials
    discord
    telegram-desktop

    # fonts
    khmeros # this sucks
    nerd-fonts.fira-code
    nerd-fonts.victor-mono

    # qol
    lsd
    mesa
    chafa
    swappy
    nautilus
    tesseract
    hyprpicker
    pavucontrol
    gnome-system-monitor
    xdg-desktop-portal-hyprland

    # screenshot tools
    jq
    glib
    grim
    slurp
    wf-recorder
    wl-clipboard
  ];

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  programs.neovim = {
    enable = true;
    extraLuaPackages = ps: [ ps.magick ];
    extraPackages = [ pkgs.imagemagick ];
    defaultEditor = true;
    # extraLuaConfig =  lib.fileContents ./dotfilesnvim/init.lua;
    # extraLuaConfig = ''dofile("${config.users.users.kuro.home}/dotfiles/nvim/init.lua")'';
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "wezterm";
        layer = "overlay";
        font = "Firacode";
      };
      colors = {
        background = "000000E6";
        text = "CDD6F4ff";
        selection = "2A2B3Cff";
        selection-text = "CDD6F4ff";
        border = "1F1D2E00";
        match = "F5A97Fff";
        selection-match = "F5A97Fff";
      };

      border = {
        radius = 17;
        width = 1;
      };
    };
  };

  programs.zsh = {
    enable = true;
    history = {
      size = 10000;
      append = true;
      share = true;
      ignoreSpace = true;
      ignoreAllDups = true;
      saveNoDups = true;
      ignoreDups = true;
      findNoDups = true;
    };
    shellAliases = {
      nsw = "sudo nixos-rebuild switch";
      ncf = "sudo nvim /etc/nixos/configuration.nix";
      hsw = "home-manager switch";
      hcf = "nvim ~/.config/home-manager/home.nix";
    };
    initExtraBeforeCompInit = lib.fileContents ./dotfiles/.zshrcA;
    initExtra = lib.fileContents ./dotfiles/.zshrcB;
  };

  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = lib.fileContents ./dotfiles/.wezterm.lua;
  };

  programs.git = {
    enable = true;
    extraConfig = lib.fileContents ./dotfiles/.gitconfig;
  };

  programs.hyprlock = {
    enable = true;
    extraConfig = lib.fileContents ./dotfiles/hypr/hyprlock.conf;
  };

  services.cliphist.enable = true;

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
      };

      listener = [
        {
          timeout = 180; # 3mins
          on-timeout = "loginctl lock-session";
        }

        {
          timeout = 240; # 4mins
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }

        {
          timeout = 540;
          on-timeout = "pidof steam || systemctl suspend || loginctl suspend";
        }
      ];
    };
  };

  services.gammastep = {
    enable = true;
    longitude = "104.888535";
    latitude = "11.562108";
  };

  services.swww = { enable = true; };

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = lib.fileContents ./dotfiles/hypr/hyprland.conf;
  };

  # Optional, hint Electron apps to use Wayland:
  home.sessionVariables.NIXOS_OZONE_WL = "1";
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  fonts = {
    fontconfig = {
      defaultFonts = {
        serif = [ "Liberation Serif" ];
        sansSerif = [ "Ubuntu" ];
      };
    };
  };

  gtk = {
    enable = true;

    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Grey-Darkest";
    };

    iconTheme = {
      package = pkgs.yaru-theme;
      name = "Yaru-purple";
    };
  };
  nixpkgs.config.allowUnfree = true;
}

# TODO: merge file from /etc/nixos/configuration.nix to this repo
# TODO: figure out nvim config
# TODO: clean up unused scripts
# TODO: get notifs and notifs history working
# TODO: fkeys on keyboard
# TODO: get home manager in repo

