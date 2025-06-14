{ inputs, config, lib, pkgs, ... }:

{
  # Imports
  imports = [ inputs.hyprpanel.homeManagerModules.hyprpanel ];

  # Home Configuration
  home = {
    stateVersion = "24.11"; # DO NOT CHANGE
    username = "kuro";
    homeDirectory = "/home/${config.home.username}";
    preferXdgDirectories = true;
    sessionVariables = { NIXOS_OZONE_WL = "1"; };

    file = {
      ".config/background" = {
        source = "${config.home.homeDirectory}/dotfiles/wallpaper/tunnel.png";
      };
      ".config/nvim" = {
        source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/dotfiles/nvim";
      };
    };

    packages = with pkgs; [
      # Languages
      gcc
      libgcc
      gnumake
      lua
      openjdk
      rustc
      cargo
      pnpm_9
      python3
      sqlite
      luarocks
      nodejs_23
      postgresql

      # Development Tools
      fd
      vscode
      fzf
      redis
      croc
      mqttx
      sshfs
      docker
      prisma
      libgtop
      docker-compose
      ripgrep
      starship
      magic-wormhole
      gitAndTools.gh
      dragon-drop

      # Social Applications
      brave
      discord
      telegram-desktop

      # Fonts
      khmeros
      nerd-fonts.fira-code
      nerd-fonts.victor-mono

      # Quality of Life
      vlc
      ags
      lsd
      newt
      mesa
      chafa
      zip
      unzip
      linux-firmware
      ffmpeg
      playerctl
      swappy
      matugen
      carapace
      tesseract
      libnotify
      hyprpicker
      pavucontrol
      xdg-user-dirs
      brightnessctl
      xdg-desktop-portal-hyprland

      openssl

      # Screenshot Tools
      jq
      glib
      grim
      slurp
      imagemagick
      wf-recorder
      wl-clipboard
    ];
  };

  # Nix Settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Programs
  programs = {

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
      silent = true;
    };

    bottom = { enable = true; };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    neovim = {
      enable = true;
      viAlias = true;
      extraLuaPackages = ps: [ ps.magick ];
      defaultEditor = true;
    };

    yazi = {
      enable = true;
      enableZshIntegration = true;
      keymap.manager.prepend_keymap = [
        {
          on = "i";
          run = "spot";
        }
        {
          on = [ "g" "r" ];
          run = ''shell -- ya emit cd "$(git rev-parse --show-toplevel)"'';
          desc = "Go to git root";
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
          on = "P";
          run = "shell -- wl-paste > pasted-image.png";
          desc = "Paste image from clipboard";
        }

        {
          on = "z";
          run = "plugin zoxide";
        }
        {
          run = "quit";
          on = [ "Z" "Z" ];
        }
      ];
      settings.manager.show_hidden = true;
      shellWrapperName = "y";
    };

    fuzzel = {
      enable = true;
      settings = {
        main = {
          dpi-aware = "no";
          terminal = "wezterm";
          layer = "overlay";
          font = "System-ui";
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

    zsh = {
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
        pysrc = "source .venv/bin/activate";
        pyenv = "py -m venv .venv && pysrc";
        nsh = "nix-shell --run zsh";
        ncf = "yazi ~/dotfiles/nix";
      };
      initExtra =
        lib.fileContents "${config.home.homeDirectory}/dotfiles/.zshrc";
    };

    wezterm = {
      enable = true;
      enableZshIntegration = true;
      extraConfig =
        lib.fileContents "${config.home.homeDirectory}/dotfiles/.wezterm.lua";
    };

    hyprpanel = {
      enable = true;
      hyprland.enable = true;
      overwrite.enable = true;
      overlay.enable = true;

      settings = {
        bar = {
          media.show_active_only = true;

          clock = {
            icon = "";
            format = "%I:%M %p";
          };

          customModules = {
            worldclock.format = "%I:%M %p %Z";
            worldclock.formatDiffDate = "%a %b %d  %I:%M %p %Z";
          };

          workspaces = {
            applicationIconOncePerWorkspace = true;
            showAllActive = true;
            showApplicationIcons = true;
            showWsIcons = true;
          };

          notifications = {
            hideCountWhenZero = true;
            show_total = true;
          };
        };

        notifications = {
          position = "top";
          showActionsOnHover = true;
        };

        menus = {
          clock = {
            time.hideSeconds = true;
            weather.location = "Phnom Penh";
            weather.unit = "metric";
          };
          power.lowBatteryNotification = true;
        };

        wallpaper = {
          enable = true;
          image = "${config.home.homeDirectory}/dotfiles/wallpaper/tunnel.png";
        };
      };

      override.theme = {
        matugen = true;
        matugen_settings = {
          mode = "dark";
          scheme_type = "neutral";
          variation = "standard_1";
        };
        osd = {
          enable = true;
          orientation = "horizontal";
          location = "top";
          icon_container = "#131315";
          icon = "#cdd6f4";
        };
        font = {
          size = "1rem";
          weight = 400;
          name = "System-ui";
        };
        bar = {
          transparent = true;
          outer_spacing = "0.2em";
          buttons.y_margins = "0.4em";
        };
        notification = {
          close_button.label = "#cdd6f4";
          close_button.background = "#303032";
        };
      };
    };

    git = {
      enable = true;
      extraConfig =
        lib.fileContents "${config.home.homeDirectory}/dotfiles/.gitconfig";
    };

    hyprlock = {
      enable = true;
      extraConfig = lib.fileContents
        "${config.home.homeDirectory}/dotfiles/hypr/hyprlock.conf";
    };
  };

  # Services
  services = {
    cliphist.enable = true;
    hyprpolkitagent.enable = true;

    hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = [
          {
            timeout = 3 * 60;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 5 * 60;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 10 * 60;
            on-timeout = "systemctl suspend || loginctl suspend";
          }
        ];
      };
    };

    gammastep = {
      enable = true;
      longitude = "104.888535";
      latitude = "11.562108";
    };

    swww.enable = true;
  };

  # Wayland Configuration
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = lib.fileContents
      "${config.home.homeDirectory}/dotfiles/hypr/hyprland.conf";
  };

  # Cursor Configuration
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  # GTK Configuration
  gtk = {
    enable = true;

    theme = {
      package = pkgs.gnome-themes-extra;
      name = "Adwaita-dark";
    };

    iconTheme = {
      package = pkgs.yaru-theme;
      name = "Yaru-purple";
    };
  };

  # QT Configuration
  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
  };
}
