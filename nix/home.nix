{ inputs, config, lib, pkgs, ... }:

{
  imports = [ inputs.hyprpanel.homeManagerModules.hyprpanel ];

  home.stateVersion = "24.11"; # DO NOT CHANGE
  home.username = "kuro";
  home.homeDirectory = "/home/kuro";
  home.preferXdgDirectories = true;

  xdg = {
    enable = true;
    userDirs.enable = true;
  };

  home.file = {
    ".config/nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles/nvim";
    };

    ".config/xdg-desktop-portal-termfilechooser/config".text = ''
      [filechooser]
      cmd=yazi
    '';
  };

  home.packages = with pkgs; [

    # languages
    gcc
    lua
    rustc
    cargo
    pnpm_9
    python3
    sqlite
    luarocks
    nodejs_23

    # dev tools
    fd
    fzf
    croc
    xclip
    sshfs
    docker
    prisma
    docker-compose
    gnumake
    ripgrep
    starship
    magic-wormhole
    gitAndTools.gh
    dragon-drop

    # socials
    brave
    discord
    telegram-desktop

    # fonts
    khmeros # this sucks
    nerd-fonts.fira-code
    nerd-fonts.victor-mono

    # qol
    vlc
    lsd
    newt
    mesa
    chafa
    unzip
    swappy
    nautilus
    tesseract
    libnotify
    hyprpicker
    pavucontrol
    xdg-user-dirs
    brightnessctl
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

  nix = { settings.experimental-features = [ "nix-command" "flakes" ]; };

  programs.neovim = {
    enable = true;
    viAlias = true;
    extraLuaPackages = ps: [ ps.magick ];
    defaultEditor = true;
    extraPackages = with pkgs; [
      bash-language-server
      biome
      black
      vscode-langservers-extracted
      docker-compose-language-service
      dockerfile-language-server-nodejs
      hadolint
      lua-language-server
      markdownlint-cli2
      nixfmt-classic
      marksman
      nil
      pyright
      ruff
      shellcheck
      shfmt
      sqlfluff
      stylua
      tailwindcss-language-server
      texlab
      vtsls
    ];
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    keymap = {
      manager.prepend_keymap = [
        {
          on = "i";
          run = "spot";
        }
        {
          on = [ "g" "r" ];
          run = ''shell -- ya emit cd "$(git rev-parse --show-toplevel)"'';
          description = "Go to git root";
        }
        {
          on = "<C-n>";
          run = ''shell -- dragon-drop -x -i -a -T "$@"'';

        }
        {
          on = "y";
          run = [
            ''
              shell -- for path in "$@"; do echo "file://$path"; done | wl-copy -t text/uri-list''
            "yank"
          ];
        }
        {
          run = "quit";
          on = [ "Z" "Z" ];
        }
      ];
    };
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        dpi-aware = "no";
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

  programs.hyprpanel = {
    enable = true;
    hyprland.enable = true;
    overwrite.enable = true;
    overlay.enable = true;

    settings = {
      theme = {
        name = "monochrome";
        bar.transparent = true;
        osd = {
          enable = true;
          orientation = "horizontal";
          location = "top";
        };
        font = {
          size = "1rem";
          weight = 400;
          name = "System-ui";
        };

        bar = {
          outer_spacing = "0.4em";
          buttons.y_margins = "0.4em";
        };
      };

      layout = {
        "bar.layouts" = {
          "*" = {
            left = [ "hypridle" "windowtitle" ];
            middle = [ "media" "workspaces" "clock" "battery" ];
            right = [ "systray" "notifications" "volume" "network" ];
          };
        };
      };

      bar = {
        clock.icon = "";
        clock.format = "%I:%M %p";
        customModules.worldclock.format = "%I:%M %p %Z";
        customModules.worldclock.formatDiffDate = "%a %b %d  %I:%M %p %Z";
        media.show_active_only = true;
        notifications.hideCountWhenZero = true;
        notifications.show_total = true;
        workspaces.applicationIconOncePerWorkspace = true;
        workspaces.showAllActive = true;
        workspaces.showApplicationIcons = true;
        workspaces.showWsIcons = true;

      };

      notifications = {
        position = "top";
        showActionsOnHover = true;
      };

      menus = {
        clock.time.hideSeconds = true;
        clock.weather.location = "Phnom Penh";
        clock.weather.unit = "metric";
      };

      wallpaper.enable = true;
      wallpaper.image =
        "${config.home.homeDirectory}/dotfiles/wallpaper/tunnel.png";

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
      nsw =
        "cd ~/dotfiles && git pull && sudo nixos-rebuild switch --flake ~/dotfiles/nix --impure && cd -";
      ncf = "yazi ~/dotfiles/nix";
    };
    initExtraBeforeCompInit =
      lib.fileContents "${config.home.homeDirectory}/dotfiles/.zshrcA";
    initExtra =
      lib.fileContents "${config.home.homeDirectory}/dotfiles/.zshrcB";
  };

  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig =
      lib.fileContents "${config.home.homeDirectory}/dotfiles/.wezterm.lua";
  };

  programs.git = {
    enable = true;
    extraConfig =
      lib.fileContents "${config.home.homeDirectory}/dotfiles/.gitconfig";
  };

  programs.hyprlock = {
    enable = true;
    extraConfig = lib.fileContents
      "${config.home.homeDirectory}/dotfiles/hypr/hyprlock.conf";
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
    extraConfig = lib.fileContents
      "${config.home.homeDirectory}/dotfiles/hypr/hyprland.conf";
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

  qt = {
    enable = true;
    platformTheme = "gtk";
    qt.style.name = "adwaita-dark";
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
