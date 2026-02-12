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
      inputs.hypr-dynamic-cursors.packages.${pkgs.stdenv.hostPlatform.system}.hypr-dynamic-cursors
    ];
    extraConfig = "
      source=${./hypr/general.conf}
      source=${./hypr/rules.conf}
      source=${./hypr/keybinds.conf}";
  };
}
