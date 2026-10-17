{config, ...}: let
  inherit (config) username;
  mac = "04:7c:16:e1:5a:dc"; # desktop enp5s0 (r8169)
in {
  flake.modules.nixos.host-desktop = {pkgs, ...}: {
    # NetworkManager owns enp5s0 and its profile defers to this default; 64 = magic packet.
    networking.networkmanager.settings.connection."ethernet.wake-on-lan" = 64;

    # Blank the ly greeter's console (DPMS off via fbcon); any key brings it back.
    systemd.services.screen-off = {
      description = "Blank the console after a remote wake";
      after = ["display-manager.service"];
      serviceConfig.Type = "oneshot";
      script = ''
        tty=/dev/tty$(${pkgs.kbd}/bin/fgconsole)
        ${pkgs.util-linux}/bin/setterm --term linux --blank force <"$tty" >"$tty"
      '';
    };
    # Lets wake-desktop on the server start it over Tailscale SSH without a password.
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" &&
            action.lookup("unit") == "screen-off.service" &&
            action.lookup("verb") == "start" &&
            subject.user == "${username}") {
          return polkit.Result.YES;
        }
      });
    '';
  };

  # Only the server is guaranteed to share the desktop's LAN; other hosts relay through it.
  flake.modules.homeManager.base = {
    pkgs,
    osConfig,
    ...
  }: {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "wake-desktop";
        runtimeInputs = [pkgs.wakeonlan];
        text =
          if osConfig.networking.hostName == "server"
          then ''
            # Broadcast on the home LAN (wlo1); WoL needs only the MAC, not the desktop's IP.
            wakeonlan -i 192.168.0.255 ${mac}
            # Wait for the boot (up to ~5 min), then turn its screens off.
            for _ in $(seq 60); do
              if timeout 10 tailscale ssh desktop -- systemctl start screen-off.service </dev/null 2>/dev/null; then
                echo "desktop up, screens off"
                exit 0
              fi
              sleep 5
            done
            echo "desktop did not come up" >&2
            exit 1
          ''
          else ''
            exec tailscale ssh server -- /etc/profiles/per-user/${username}/bin/wake-desktop
          '';
      })
    ];
  };
}
