{...}: {
  flake.modules.nixos.host-server = {pkgs, ...}: {
    # Keyboard backlight (MSI GT683R, gt683r_led: front/side/back zones) off.
    # Firmware lights it at power-on while the driver reports 0, so toggle 1→0
    # to actually send the "off" packet.
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="leds", DRIVERS=="gt683r_led", RUN+="${pkgs.runtimeShell} -c 'echo 1 > /sys%p/brightness; echo 0 > /sys%p/brightness'"
    '';

    # Don't suspend when lid closes (server must keep running)
    services.logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
    };

    # Blank/restore backlight hardware on lid events
    services.acpid = {
      enable = true;
      handlers = {
        lid-close = {
          event = "button/lid LID close";
          action = ''
            for f in /sys/class/backlight/*/brightness; do
              echo 0 > "$f" 2>/dev/null || true
            done
          '';
        };
        lid-open = {
          event = "button/lid LID open";
          action = ''
            for f in /sys/class/backlight/*/max_brightness; do
              cat "$f" > "''${f%max_brightness}brightness" 2>/dev/null || true
            done
          '';
        };
      };
    };
  };
}
