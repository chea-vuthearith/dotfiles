{ config, pkgs, inputs, ... }:
let awww = inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww;
in {
  home.packages = [ awww ];
  systemd.user.services.awww-daemon = {
    Unit = {
      Description = "Awww Wallpaper Daemon";
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${awww}/bin/awww-daemon";
      Restart = "always";
    };
    Install = { WantedBy = [ "default.target" ]; };
  };

  home.activation.awwwWallpaper = ''
    if ! ${pkgs.procps}/bin/pgrep -x awww-daemon > /dev/null; then
      (${awww}/bin/awww-daemon &)
    fi
    ${awww}/bin/awww img ${config.wallpaperPath}
  '';

}
