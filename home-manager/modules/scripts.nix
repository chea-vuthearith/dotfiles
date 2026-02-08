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

  record-script = pkgs.writeShellApplication {
    name = "record-script";
    runtimeInputs = with pkgs; [
      wf-recorder
      hyprland
      jq
      slurp
      libnotify
      wl-clipboard
      pulseaudio
      xdg-user-dirs
      coreutils
      procps
      gawk
    ];
    text = builtins.readFile ../../scripts/record-script.sh;
  };
in {
  home.packages = [
    grimblast
    record-script
  ];
}
