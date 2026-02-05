{
  config,
  pkgs,
  inputs,
  ...
}: let
  awww = inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww;
in {
  services.swww = {
    enable = true;
    package = pkgs.symlinkJoin {
      name = "awww-with-swww-daemon";
      paths = [awww];
      postBuild = ''
        ln -s $out/bin/awww-daemon $out/bin/swww-daemon
      '';
    };
  };

  home.activation.awwwWallpaper = ''
    if ! ${pkgs.procps}/bin/pgrep -x awww-daemon > /dev/null; then
      (${awww}/bin/awww-daemon &)
    fi
    ${awww}/bin/awww img ${config.wallpaperPath}
  '';
}
