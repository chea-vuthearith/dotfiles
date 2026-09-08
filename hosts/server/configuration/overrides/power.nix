{...}: {
  # Don't suspend when lid closes (server must keep running)
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
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
}
