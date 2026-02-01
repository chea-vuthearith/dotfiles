{ config, pkgs, inputs, ... }:
let awww = inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww;
in {
  home.packages = [ awww ];
  # home.activation.awwwWallpaper = {
  #   text = "Set awww wallpaper";
  #   script = ''
  #     awww-daemon
  #     ${awww}/bin/awww img ${config.wallpaperPath} --transition-fade
  #   '';
  # };
  #
}
