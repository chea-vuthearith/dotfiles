{
  pkgs,
  config,
  ...
}: let
  grimblast = pkgs.writeShellApplication {
    name = "grimblast";
    runtimeInputs = with pkgs; [
      grim
      slurp
      hyprland
      hyprpicker
      wl-clipboard
      jq
      libnotify
      coreutils
      gnugrep
    ];
    text = builtins.readFile ../../scripts/grimblast.sh;
  };
in {
  home.packages = [
    grimblast
  ];
}
