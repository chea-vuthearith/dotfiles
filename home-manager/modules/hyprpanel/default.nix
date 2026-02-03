{
  pkgs,
  inputs,
  config,
  ...
}: {
  home.file = {
    ".config/hyprpanel/modules.scss" = {source = ./modules.scss;};
    ".config/hyprpanel/modules.json" = {source = ./modules.json;};
  };
  programs.hyprpanel = {
    enable = true;
    package =
      inputs.hyprpanel.packages.${pkgs.stdenv.hostPlatform.system}.hyprpanel;
    settings =
      builtins.fromJSON (builtins.readFile ./catppuccin_mocha.json)
      // {
        bar = {
          autoHide = "fullscreen";
          network.label = false;
          media.show_active_only = true;
          bluetooth = {label = false;};
          volume = {label = false;};
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
          image = config.wallpaperPath;
        };
        theme = {
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
}
