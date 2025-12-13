{ inputs, config, lib, pkgs, ... }:
let
  wallpaperPath =
    "${config.home.homeDirectory}/dotfiles/wallpaper/red-nebulae.jpg";
in {
  imports = [ ];
  # Home Configuration
  home = {
    stateVersion = "24.11"; # DO NOT CHANGE
    username = "kuro";
    homeDirectory = "/home/${config.home.username}";
    preferXdgDirectories = true;
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      TERMCMD = "wezterm start --always-new-process";
      NIXPKGS_ALLOW_UNFREE = 1;
    };

    file = {
      ".config/nvim" = {
        source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/dotfiles/nvim";
      };
      ".config/hyprpanel/modules.scss" = {
        source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/dotfiles/hyprpanel/modules.scss";
      };
      ".config/hyprpanel/modules.json" = {
        source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/dotfiles/hyprpanel/modules.json";
      };
    };

    packages = with pkgs; [
      # Programming Languages & Runtimes
      gcc
      libgcc
      gnumake
      gnused
      lua
      openjdk
      rustc
      cargo
      python3
      nodejs_24
      pnpm_10
      turbo
      sqlite
      postgresql
      uv

      # Editors & IDEs
      vscode
      ios-webkit-debug-proxy
      anydesk

      # Dev Utilities & CLI Tools
      aria2
      fd
      fzf
      ripgrep
      jq
      glib
      xdg-user-dirs
      zip
      unzip
      unrar
      openssl
      starship
      lsd
      carapace
      keychain
      newt
      libgtop
      xorg.xrandr

      # Containers & Cloud
      docker
      docker-compose
      prisma
      prisma-engines
      magic-wormhole
      croc
      sshfs
      mqttx
      redis

      # Media & Graphics
      mpv
      ffmpeg
      imagemagick
      playerctl
      tesseract
      wf-recorder
      swappy
      matugen
      hyprpicker

      # Desktop & System
      ags
      mesa
      linux-firmware
      libnotify
      pavucontrol
      brightnessctl
      dragon-drop
      hyprpaper
      hypridle
      abiword

      # Browsers & Communication
      brave
      discord
      telegram-desktop

      # Clipboard & Screenshot Tools
      grim
      slurp
      wl-clipboard
    ];

    # Cursor Configuration
    pointerCursor = {
      gtk.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
    };
  };

  # Nix Settings
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
      keymap.mgr.prepend_keymap = [
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
        {
          on = "<Down>";
          run = [ "seek 1" ];
        }
        {
          on = "<Up>";
          run = [ "seek -1" ];
        }
      ];
      settings = {
        mgr.show_hidden = true;
        preview.max_width = 1600;
        preview.max_height = 1440;
      };
      shellWrapperName = "y";
    };

    fuzzel = {
      enable = true;
      settings = {
        main = {
          dpi-aware = "no";
          terminal = "wezterm start --always-new-process";
          layer = "overlay";
          font = "System-ui";
        };
        colors = {
          background = "000000E6";
          border = "000000E6";
          text = "cdd6f4ff";
          prompt = "bac2deff";
          placeholder = "7f849cff";
          input = "cdd6f4ff";
          match = "f38ba8ff";
          selection = "585b70ff";
          selection-text = "cdd6f4ff";
          selection-match = "f38ba8ff";
          counter = "7f849cff";
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
        wgu = "sudo systemctl start wg-quick-wg0.service";
        wgd = "sudo systemctl stop wg-quick-wg0.service";
        dl =
          "aria2c --console-log-level=error --max-connection-per-server=16 --max-concurrent-downloads=16 --split=16 --continue=true --dir=$HOME/Downloads";
      };
      initContent =
        lib.fileContents "${config.home.homeDirectory}/dotfiles/zshrc";
    };

    wezterm = {
      enable = true;
      enableZshIntegration = true;
      extraConfig =
        lib.fileContents "${config.home.homeDirectory}/dotfiles/wezterm.lua";
    };

    hyprpanel = {
      enable = true;
      package = inputs.hyprpanel.packages.${pkgs.system}.hyprpanel;

      settings = builtins.fromJSON (builtins.readFile
        "${config.home.homeDirectory}/dotfiles/hyprpanel/catppuccin_mocha.json")
        // {
          bar = {
            autoHide = "fullscreen";
            network.label = false;
            media.show_active_only = true;

            bluetooth = { label = false; };

            volume = { label = false; };

            clock = {
              icon = "";
              format = "%A %I:%M %p";
            };

            customModules = {
              worldclock.format = "%I:%M %p %Z";
              worldclock.formatDiffDate = "%a %b %d  %I:%M %p %Z";
              hypridle.label = false;
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
            position = "bottom right";
            clearDelay = 0;
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
            enable = false;
            image = wallpaperPath;
          };

          theme = {
            # matugen_settings = {
            #   mode = "dark";
            #   scheme_type = "monochrome";
            #   variation = "standard_1";
            # };
            osd = {
              enable = true;
              orientation = "horizontal";
              location = "bottom";
            };
            font = {
              size = "0.875rem";
              weight = 400;
              name = "System-ui";
            };
            bar = {
              transparent = true;
              outer_spacing = "0.2em";
              buttons.y_margins = "0.4em";
              location = "bottom";
              buttons.background_opacity = 30;
            };
          };
        };

    };

    git = {
      enable = true;
      userName = "chea-vuthearith";
      userEmail = "cheavuthearith0@gmail.com";
      extraConfig = {
        credential."https://github.com".helper =
          "!${pkgs.coreutils}/bin/env gh auth git-credential";
        credential."https://gist.github.com".helper =
          "!${pkgs.coreutils}/bin/env gh auth git-credential";
        safe.directory = "*";
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        pull.rebase = true;
        rerere.enabled = true;
      };
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
            on-timeout = "systemctl suspend-then-hibernate";
          }
        ];
      };
    };

    gammastep = {
      enable = true;
      longitude = "104.888535";
      latitude = "11.562108";
    };

    hyprpaper = {
      enable = true;
      settings = {
        splash = false;
        preload = [ wallpaperPath ];
        wallpaper = [ ", ${wallpaperPath}" ];

      };
    };
  };

  # Wayland Configuration
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    plugins = [
      inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
    ];
    extraConfig = lib.fileContents
      "${config.home.homeDirectory}/dotfiles/hypr/hyprland.conf";
  };

  xdg = {
    enable = true;
    portal = {
      extraPortals = [ pkgs.xdg-desktop-portal-termfilechooser ];
      config.common = {
        "org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
      };
    };
    configFile."xdg-desktop-portal-termfilechooser/config" = {
      force = true;
      text = ''
        [filechooser]
        cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
        create_help_file=0
        env=TERMCMD=wezterm start --always-new-process
        default_dir=$HOME
        open_mode=suggested
        save_mode=last
      '';
    };
    userDirs = {
      createDirectories = true;
      enable = true;
    };
    desktopEntries = {
      "poweroff" = {
        name = "Power Off";
        comment = "Shut down the computer";
        exec = "poweroff";
        categories = [ "System" "Utility" ];
      };
    };
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
