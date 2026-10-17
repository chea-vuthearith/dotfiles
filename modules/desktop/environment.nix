{...}: {
  flake.modules.nixos.desktop = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      dconf
      dbus

      # libs
      glib
      libgtop
      libnotify
    ];
  };
  flake.modules.homeManager.desktop = {...}: {
    home.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
