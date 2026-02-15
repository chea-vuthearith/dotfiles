{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];
  home = {
    file = {
      "${config.xdg.stateHome}/caelestia/wallpaper/path.txt".text = toString config.stylix.image;

      "${config.xdg.stateHome}/caelestia/scheme.json" = {
        text = builtins.toJSON {
          name = "stylix-generated";
          flavour = "custom";
          mode = config.stylix.polarity;
          variant = "tonalspot";
          colours = with config.lib.stylix.colors; {
            # Material Design 3 palette key colors
            primary_paletteKeyColor = base0D;
            secondary_paletteKeyColor = base04;
            tertiary_paletteKeyColor = base0E;
            neutral_paletteKeyColor = base03;
            neutral_variant_paletteKeyColor = base04;

            # Background colors
            background = base00;
            onBackground = base05;

            # Surface colors
            surface = base00;
            surfaceDim = base00;
            surfaceBright = base03;
            surfaceContainerLowest = base00;
            surfaceContainerLow = base01;
            surfaceContainer = base01;
            surfaceContainerHigh = base02;
            surfaceContainerHighest = base03;

            onSurface = base05;
            surfaceVariant = base02;
            onSurfaceVariant = base04;

            inverseSurface = base05;
            inverseOnSurface = base00;

            # Outline colors
            outline = base03;
            outlineVariant = base02;

            # Utility colors
            shadow = "000000";
            scrim = "000000";
            surfaceTint = base0D;

            # Primary colors (blue family - closest to "c2c1ff")
            primary = base07;
            onPrimary = base01;
            primaryContainer = base0D;
            onPrimaryContainer = base00;
            inversePrimary = base03;

            # Secondary colors (neutral gray family - closest to "c6c4e0")
            secondary = base04;
            onSecondary = base00;
            secondaryContainer = base03;
            onSecondaryContainer = base05;

            # Tertiary colors (pink/mauve family - closest to "f5b2e0")
            tertiary = base0E;
            onTertiary = base00;
            tertiaryContainer = base0E;
            onTertiaryContainer = base00;

            # Error colors
            error = base08;
            onError = base00;
            errorContainer = base01;
            onErrorContainer = base08;

            # Fixed colors
            primaryFixed = base07;
            primaryFixedDim = base0D;
            onPrimaryFixed = base00;
            onPrimaryFixedVariant = base01;

            secondaryFixed = base04;
            secondaryFixedDim = base03;
            onSecondaryFixed = base00;
            onSecondaryFixedVariant = base01;

            tertiaryFixed = base0E;
            tertiaryFixedDim = base0E;
            onTertiaryFixed = base00;
            onTertiaryFixedVariant = base01;

            # Terminal colors (standard base16 terminal mapping)
            term0 = base00;
            term1 = base08;
            term2 = base0B;
            term3 = base0A;
            term4 = base0D;
            term5 = base0E;
            term6 = base0C;
            term7 = base05;
            term8 = base03;
            term9 = base08;
            term10 = base0B;
            term11 = base0A;
            term12 = base0D;
            term13 = base0E;
            term14 = base0C;
            term15 = base07;

            # Catppuccin-style extended colors
            rosewater = base06;
            flamingo = base06;
            pink = base0E;
            mauve = base0E;
            red = base08;
            maroon = base08;
            peach = base09;
            yellow = base0A;
            green = base0B;
            teal = base0C;
            sky = base0C;
            sapphire = base0C;
            blue = base0D;
            lavender = base0D;

            # Custom k-prefixed colors
            klink = base0D;
            klinkSelection = base0D;
            kvisited = base0E;
            kvisitedSelection = base0E;
            knegative = base08;
            knegativeSelection = base08;
            kneutral = base0A;
            kneutralSelection = base0A;
            kpositive = base0B;
            kpositiveSelection = base0B;

            # Text hierarchy colors
            text = base05;
            subtext1 = base04;
            subtext0 = base03;

            # Overlay colors
            overlay2 = base03;
            overlay1 = base02;
            overlay0 = base02;

            # Additional surface colors
            surface2 = base02;
            surface1 = base01;
            surface0 = base01;

            # Base colors
            base = base00;
            mantle = base00;
            crust = base00;

            # Success colors
            success = base0B;
            onSuccess = base00;
            successContainer = base03;
            onSuccessContainer = base0B;
          };
        };
      };
    };
  };

  programs.caelestia = {
    enable = true;
    systemd = {
      enable = true;
      target = "graphical-session.target";
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
          explorer = ["wezterm" "start" "--always-new-process" "yazi"];
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
        actions = [
          {
            name = "Calculator";
            icon = "calculate";
            description = "Do simple math equations (powered by Qalc)";
            command = ["autocomplete" "calc"];
            enabled = true;
            dangerous = false;
          }

          {
            name = "Scheme";
            icon = "palette";
            description = "Change the current colour scheme";
            command = ["autocomplete" "scheme"];
            enabled = true;
            dangerous = false;
          }

          {
            name = "Wallpaper";
            icon = "image";
            description = "Change the current wallpaper";
            command = ["autocomplete" "wallpaper"];
            enabled = true;
            dangerous = false;
          }

          {
            name = "Variant";
            icon = "colors";
            description = "Change the current scheme variant";
            command = ["autocomplete" "variant"];
            enabled = true;
            dangerous = false;
          }

          {
            name = "Transparency";
            icon = "opacity";
            description = "Change shell transparency";
            command = ["autocomplete" "transparency"];
            enabled = false;
            dangerous = false;
          }

          {
            name = "Random";
            icon = "casino";
            description = "Switch to a random wallpaper";
            command = ["caelestia" "wallpaper" "-r"];
            enabled = true;
            dangerous = false;
          }

          {
            name = "Light";
            icon = "light_mode";
            description = "Change the scheme to light mode";
            command = ["setMode" "light"];
            enabled = true;
            dangerous = false;
          }

          {
            name = "Dark";
            icon = "dark_mode";
            description = "Change the scheme to dark mode";
            command = ["setMode" "dark"];
            enabled = true;
            dangerous = false;
          }

          {
            name = "Poweroff";
            icon = "power_settings_new";
            description = "Shutdown the system";
            command = ["systemctl" "poweroff"];
            enabled = true;
            dangerous = true;
          }

          {
            name = "Reboot";
            icon = "cached";
            description = "Reboot the system";
            command = ["systemctl" "reboot"];
            enabled = true;
            dangerous = true;
          }

          {
            name = "Logout";
            icon = "exit_to_app";
            description = "Log out of the current session";
            command = ["loginctl" "terminate-user" ""];
            enabled = true;
            dangerous = true;
          }

          {
            name = "Lock";
            icon = "lock";
            description = "Lock the current session";
            command = ["loginctl" "lock-session"];
            enabled = true;
            dangerous = false;
          }

          {
            name = "Sleep";
            icon = "bedtime";
            description = "Suspend then hibernate";
            command = ["systemctl" "suspend-then-hibernate"];
            enabled = true;
            dangerous = false;
          }

          {
            name = "Settings";
            icon = "settings";
            description = "Configure the shell";
            command = ["caelestia" "shell" "controlCenter" "open"];
            enabled = true;
            dangerous = false;
          }
        ];
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
      services = {
        useFahrenheit = false;
        useTwelveHourClock = true;
      };
      utilities = {
        toasts = {
          configLoaded = false;
          numLockChanged = false;
          nowPlaying = false;
        };
        vpn.enabled = false;
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
