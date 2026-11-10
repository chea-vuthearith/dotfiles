{config, ...}: let
  inherit (config) username;
in {
  flake.modules.nixos.host-desktop = {
    # Agents power off the desktop they woke, over Tailscale SSH (`systemctl poweroff`).
    # That session is non-local, so logind's default polkit policy wants a password; after a
    # wake-on-LAN boot nobody is logged in at ly either. Power-off only: no reboot/suspend.
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if ((action.id == "org.freedesktop.login1.power-off" ||
             action.id == "org.freedesktop.login1.power-off-multiple-sessions") &&
            subject.user == "${username}") {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
