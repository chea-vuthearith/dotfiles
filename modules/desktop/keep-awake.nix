{...}: {
  flake.modules.homeManager.desktop = {pkgs, ...}: let
    # Toggle with SUPER+C (binds below). While on:
    # - logind ignores the lid and refuses idle/sleep (block inhibitor held by keep-awake.service)
    # - DMS idle inhibit is on, so the shell does not lock/blank/suspend on idle
    # - closing the lid only sets the backlight to 0; opening restores it
    keep-awake = pkgs.writeShellApplication {
      name = "keep-awake";
      runtimeInputs = with pkgs; [brightnessctl libnotify systemd coreutils];
      text = ''
        saved="''${XDG_RUNTIME_DIR:?}/keep-awake-brightness"

        active() { systemctl --user is-active --quiet keep-awake.service; }

        restore() {
          [ -e "$saved" ] || return 0
          brightnessctl --quiet set "$(cat "$saved")"
          rm -f "$saved"
        }

        case "''${1:-toggle}" in
          toggle)
            if active; then
              systemctl --user stop keep-awake.service
              dms ipc call inhibit disable >/dev/null || true
              restore
              notify-send -a "Keep awake" "Keep awake off" "Lid close and idle behave normally"
            else
              systemctl --user start keep-awake.service
              dms ipc call inhibit enable >/dev/null || true
              notify-send -a "Keep awake" "Keep awake on" "Closing the lid only turns the screen off"
            fi
            ;;
          lid-close)
            active || exit 0
            [ -e "$saved" ] || brightnessctl get >"$saved"
            brightnessctl --quiet set 0
            ;;
          lid-open)
            restore
            ;;
          status)
            if active; then echo on; else echo off; fi
            ;;
          *)
            echo "usage: keep-awake [toggle|lid-close|lid-open|status]" >&2
            exit 2
            ;;
        esac
      '';
    };
  in {
    home.packages = [keep-awake];

    wayland.windowManager.hyprland.extraLuaFiles."keep-awake".content = ''
      hl.bind("SUPER + C", hl.dsp.exec_cmd("keep-awake toggle"))
      hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("keep-awake lid-close"), { locked = true })
      hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("keep-awake lid-open"), { locked = true })
    '';

    # Started/stopped only by `keep-awake toggle`; never at login.
    systemd.user.services.keep-awake = {
      Unit.Description = "Keep awake: block idle, sleep and lid-switch handling";
      Service.ExecStart = builtins.concatStringsSep " " [
        "${pkgs.systemd}/bin/systemd-inhibit"
        "--what=idle:sleep:handle-lid-switch"
        "--who=keep-awake"
        ''"--why=Keep-awake mode"''
        "--mode=block"
        "${pkgs.coreutils}/bin/sleep infinity"
      ];
    };
  };
}
