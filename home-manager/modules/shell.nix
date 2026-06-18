{
  pkgs,
  config,
  lib,
  ...
}: let
in {
  programs.dank-material-shell = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
    plugins = {
      dankHyprlandWindows = {
        enable = true;
        settings = {
          trigger = "w";
        };
      };
      dankBatteryAlerts = {
        enable = true;
      };
      nixPackageRunner = {
        enable = true;
        settings = {
          terminal = "ghostty";
          runSourceMode = "latest_unstable";
        };
      };
      screenRecorder = {
        enable = true;
        src = lib.mkForce (pkgs.fetchFromGitHub {
          owner = "chea-vuthearith";
          repo = "dms-screen-recorder";
          rev = "4bf9e5d20b9a582b06bbb518d0a67552ce3fdd7a";
          sha256 = "sha256-Q+TTG7h2LPvB/M4O/WuEmLHRjHJFalFspu/0bQte/Yg=";
        });
        settings = {
          captureSource = "screen";
          postRecordCommand = "wl-copy --type text/uri-list \"file://$1\"";
        };
      };
      githubNotifier = {
        enable = true;
      };
    };

    settings = rec {
      acLockTimeout = 60 * 10;
      acMonitorTimeout = 60 * 15;
      acPostLockMonitorTimeout = 60 * 3;
      acSuspendTimeout = 60 * 60;
      acSuspendBehavior = 2; # suspend then hibernate

      batteryLockTimeout = acLockTimeout;
      batteryMonitorTimeout = acMonitorTimeout;
      batteryPostLockMonitorTimeout = acPostLockMonitorTimeout;
      batterySuspendTimeout = acSuspendTimeout;
      batterySuspendBehavior = acSuspendBehavior;

      builtInPluginSettings = {
        dms_settings_search = {
          trigger = "?";
        };
        dms_clipboard_search = {
          trigger = "cb";
        };
        dms_notepad = {
          enabled = false;
        };
        dms_sysmon = {
          enabled = false;
        };
      };
      launcherPluginVisibility = {
        dms_settings_search = {
          allowWithoutTrigger = false;
        };
        dms_clipboard_search = {
          allowWithoutTrigger = false;
        };
        nixPackageRunner = {
          allowWithoutTrigger = false;
        };
        screenRecorder = {
          allowWithoutTrigger = false;
        };
      };
      launcherPluginOrder = [
        "dms_settings_search"
        "dankHyprlandWindows"
        "screenRecorder"
        "dms_clipboard_search"
        "nixPackageRunner"
      ];

      controlCenterWidgets = [
        {
          id = "volumeSlider";
          enabled = true;
          width = 50;
        }
        {
          id = "brightnessSlider";
          enabled = true;
          width = 50;
        }
        {
          id = "wifi";
          enabled = true;
          width = 50;
        }
        {
          id = "bluetooth";
          enabled = true;
          width = 50;
        }
        {
          id = "audioOutput";
          enabled = true;
          width = 50;
        }
        {
          id = "audioInput";
          enabled = true;
          width = 50;
        }
        {
          id = "doNotDisturb";
          enabled = true;
          width = 50;
        }
        {
          id = "idleInhibitor";
          enabled = true;
          width = 50;
        }
      ];

      barConfigs = [
        {
          autoHide = false;
          autoHideDelay = 250;
          borderColor = "surfaceText";
          borderEnabled = false;
          borderOpacity = 1;
          borderThickness = 1;
          bottomGap = 0;
          centerWidgets = [
            {
              id = "spacer";
              enabled = true;
              size = 20;
            }
            {
              id = "clock";
              enabled = true;
            }
            {
              id = "privacyIndicator";
              enabled = true;
            }
          ];
          enabled = true;
          fontScale = 1;
          gothCornerRadiusOverride = false;
          gothCornerRadiusValue = 12;
          gothCornersEnabled = false;
          id = "default";
          innerPadding = 4;
          leftWidgets = [
            {
              id = "workspaceSwitcher";
              enabled = true;
            }
            {
              id = "separator";
              enabled = true;
            }
            {
              id = "notificationButton";
              enabled = true;
            }
            {
              id = "githubNotifier";
              enabled = true;
            }
          ];
          maximizeDetection = true;
          name = "Main Bar";
          noBackground = false;
          openOnOverview = false;
          popupGapsAuto = true;
          popupGapsManual = 4;
          position = 1;
          rightWidgets = [
            {
              id = "systemTray";
              enabled = true;
            }
            {
              id = "controlCenterButton";
              enabled = true;
              showAudioIcon = false;
              showAudioPercent = false;
            }
            {
              id = "battery";
              enabled = true;
            }
          ];
          screenPreferences = [
            "all"
          ];
          shadowIntensity = 0;
          showOnLastDisplay = true;
          spacing = 4;
          squareCorners = false;
          transparency = 0;
          visible = true;
          widgetTransparency = 0.3;
        }
      ];

      groupActiveWorkspaceApps = true;
      launcherUseOverlayLayer = true;
      lockBeforeSuspend = true;
      lockScreenNotificationMode = 2;
      notificationCompactMode = true;
      notificationOverlayEnabled = true;
      notificationShowTimeoutBar = true;
      osdPosition = 7;
      osdMediaPlaybackEnabled = true;
      padHours12Hour = true;
      showDock = false;
      showWorkspaceApps = true;
      showWorkspaceIndex = true;
      showWorkspacePadding = true;
      soundsEnabled = false;
      spotlightBarShowModeChips = true;
      systemTrayIconTintMode = "monochrome";
      textRenderType = 1;
      updaterIntervalSeconds = 86400;
      use24HourClock = false;
      weatherEnabled = false;
      workspaceFollowFocus = false;
    };
    session = {
      nightModeAutoEnabled = true;
      nightModeEnabled = true;
      nightModeTemperature = 5000;
      nightModeUseIPLocation = true;
    };
    enableSystemMonitoring = false;
    enableVPN = false;
    enableDynamicTheming = false;
    enableAudioWavelength = false;
    enableCalendarEvents = true;
    enableClipboardPaste = true;
  };
}
