{
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];
  home.file = {
    "${config.xdg.stateHome}/caelestia/wallpaper/path.txt" = {
      text = toString config.stylix.image;
    };
  };

  programs.caelestia = {
    enable = true;
    systemd = {
      enable = true;
      target = "graphical-session.target";
      environment = [];
    };
    settings = {
      background = {
        desktopClock = {
          enabled = true;
        };
        enabled = true;
      };
      appearance = {
        font.family = {
          mono = config.stylix.fonts.monospace.name;
          sans = config.stylix.fonts.sansSerif.name;
        };
      };

      general = {
        apps = {
          terminal = ["wezterm"];
          explorer = ["yazi"];
        };
      };

      border = {
        rounding = 16;
        thickness = 8;
      };

      bar = {
        clock = {
          showIcon = false;
        };
        status = {
          showAudio = true;
          showMicrophone = true;
          showKbLayout = false;
          showNetwork = true;
          showLockStatus = false;
        };
        tray = {compact = true;};
        showOnHover = true;
        entries = [
          {
            id = "logo";
            enabled = false;
          }
          {
            id = "workspaces";
            enabled = true;
          }
          {
            id = "spacer";
            enabled = true;
          }
          {
            id = "activeWindow";
            enabled = false;
          }
          {
            id = "spacer";
            enabled = true;
          }
          {
            id = "tray";
            enabled = true;
          }
          {
            id = "clock";
            enabled = true;
          }
          {
            id = "statusIcons";
            enabled = true;
          }
          {
            id = "power";
            enabled = false;
          }
        ];
        persistent = false;
      };
      launcher = {
        enableDangerousActions = true;
        vimKeybinds = true;
        useFuzzy = {
          apps = true;
          actions = true;
          schemes = true;
          variants = true;
          wallpapers = true;
        };
      };
      paths = {
        wallpaperDir = ../../wallpapers;
        mediaGif = "";
      };
    };
    cli = {
      enable = true;
      settings = {
        theme = {
          # managed by stylix
          enableTerm = false;
          enableHypr = false;
          enableDiscord = false;
          enableSpicetify = false;
          enableFuzzel = false;
          enableBtop = false;
          enableGtk = false;
          enableQt = false;
        };
      };
    };
  };
}
