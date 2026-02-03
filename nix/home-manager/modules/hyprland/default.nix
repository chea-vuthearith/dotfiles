{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  wayland.windowManager.hyprland = {
    enable = true;
    package =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    plugins = [
      inputs.split-monitor-workspaces.packages.${pkgs.stdenv.hostPlatform.system}.split-monitor-workspaces
    ];
    extraConfig = "
      source=${./conf/env.conf}
      source=${./conf/execs.conf}
      source=${./conf/general.conf}
      source=${./conf/rules.conf}
      source=${./conf/colors.conf}
      source=${./conf/keybinds.conf}";
  };
}
