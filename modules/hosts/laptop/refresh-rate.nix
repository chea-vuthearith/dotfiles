{...}: {
  flake.modules.homeManager.host-laptop = {pkgs, ...}: let
    # eDP-1 runs 120Hz on AC, 60Hz on battery. The first power-supply event
    # switches immediately; further events are ignored until AC state has
    # been quiet for `settle` seconds, then the final state is applied once,
    # so a flaky charger connector doesn't thrash the panel.
    refresh-rate = pkgs.writeShellApplication {
      name = "refresh-rate-on-ac";
      runtimeInputs = with pkgs; [systemd coreutils hyprland];
      text = ''
        settle=5
        current=""

        apply() {
          local online rate
          online=$(cat /sys/class/power_supply/AC0/online)
          if [ "$online" = 1 ]; then rate=120; else rate=60; fi
          [ "$rate" = "$current" ] && return 0
          hyprctl eval "hl.monitor({output = \"eDP-1\", mode = \"1920x1200@$rate\", position = \"auto\", scale = \"1\"})" >/dev/null
          current=$rate
        }

        apply
        udevadm monitor --udev --subsystem-match=power_supply | while read -r _; do
          apply
          # Swallow the burst until quiet for $settle seconds, then reconcile.
          while read -r -t "$settle" _; do :; done
          apply
        done
      '';
    };
  in {
    systemd.user.services.refresh-rate-on-ac = {
      Unit = {
        Description = "Switch eDP-1 between 120Hz (AC) and 60Hz (battery)";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${refresh-rate}/bin/refresh-rate-on-ac";
        Restart = "on-failure";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
