# TODO: fix screenrecording
# find good screenshot solution
# bug when starting up system
# hide notifications
# auto install screen rec plugin
{...}: {
  programs.noctalia-shell = {
    enable = true;
    settings = {
      appLauncher = {
        enableClipboardHistory = true;
        enableSessionSearch = true;
        enableSettingsSearch = false;
        enableWindowsSearch = true;
        position = "bottom_center";
        showCategories = false;
        showIconBackground = true;
        iconMode = "tabler";
        terminalCommand = "ghostty -e";
      };

      bar = {
        displayMode = "always_visible";
        position = "bottom";
        widgets = {
          center = [
            {
              compactMode = true;
              hideMode = "idle";
              hideWhenIdle = false;
              maxWidth = 145;
              panelShowAlbumArt = true;
              scrollingMode = "hover";
              showAlbumArt = false;
              showArtistFirst = false;
              showProgressRing = true;
              showVisualizer = false;
              textColor = "none";
              useFixedWidth = false;
              visualizerType = "linear";
              id = "MediaMini";
            }
          ];

          left = [
            {
              colorizeIcons = true;
              hideMode = "hidden";
              maxWidth = 145;
              scrollingMode = "hover";
              showIcon = true;
              textColor = "none";
              useFixedWidth = false;
              id = "ActiveWindow";
            }
            {
              characterCount = 2;
              colorizeIcons = true;
              emptyColor = "primary";
              enableScrollWheel = true;
              focusedColor = "secondary";
              followFocusedScreen = false;
              fontWeight = "bold";
              groupedBorderOpacity = 1;
              hideUnoccupied = false;
              iconScale = 0.8;
              labelMode = "none";
              occupiedColor = "none";
              pillSize = 0.6;
              showApplications = false;
              showApplicationsHover = false;
              showBadge = true;
              showLabelsOnlyWhenOccupied = true;
              unfocusedIconsOpacity = 1;
              id = "Workspace";
            }
          ];

          right = [
            {
              blacklist = [];
              chevronColor = "none";
              colorizeIcons = false;
              drawerEnabled = true;
              hidePassive = false;
              pinned = [];
            }
            {
              displayMode = "graphic";
              hideIfIdle = false;
              hideIfNotDetected = true;
              showNoctaliaPerformance = false;
              showPowerProfiles = false;
              id = "Battery";
            }
            {
              colorizeDistroLogo = false;
              colorizeSystemIcon = "none";
              customIconPath = "";
              enableColorization = false;
              icon = "noctalia";
              useDistroLogo = false;
              id = "ControlCenter";
            }
            {
              id = "plugin:screen";
            }
            {
              clockColor = "none";
              customFont = "";
              formatHorizontal = "h:mm AP";
              formatVertical = "";
              tooltipFormat = "ddd MMM d h:mm:ss AP";
              useCustomFont = false;
              id = "Clock";
            }
          ];
        };
      };

      dock = {
        colorizeIcons = true;
        displayMode = "always_visible";
        dockType = "attached";
        groupApps = true;
        position = "right";
      };

      general = {
        clockFormat = "h:mm AP ";
        dimmerOpacity = 0.5;
        lockScreenAnimations = true;
        lockScreenBlur = 0.2;
        lockScreenTint = 0.2;
        showScreenCorners = true;
        keybinds = {
          keyDown = [
            "Ctrl+N"
          ];
          keyEnter = [
            "Return"
            "Enter"
          ];
          keyEscape = [
            "Esc"
          ];
          keyLeft = [
            "Ctrl+P"
          ];
          keyRemove = [
            "Del"
          ];
          keyRight = [
            "Ctrl+N"
          ];
          keyUp = [
            "Ctrl+P"
          ];
        };
      };

      idle = {
        enabled = true;
        lockTimeout = 300;
        screenOffTimeout = 180;
      };
    };
  };
  wayland.windowManager.hyprland = {
    settings = {
      exec = [
        "noctalia-shell"
      ];
    };
  };
}
