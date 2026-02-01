{ config, pkgs, inputs, ... }:
let awww = inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww;
in {
  home.packages = [ awww ];
  home.activation.awwwWallpaper = ''
    if ! pgrep -x awww-daemon > /dev/null; then
      (${awww}/bin/awww-daemon &)
    fi
    ${awww}/bin/awww img ${config.wallpaperPath}
  '';

}
