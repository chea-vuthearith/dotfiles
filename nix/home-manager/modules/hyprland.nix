{ config, pkgs, inputs, lib, ... }: {
  wayland.windowManager.hyprland = {
    enable = true;
    package =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    plugins = [
      inputs.split-monitor-workspaces.packages.${pkgs.stdenv.hostPlatform.system}.split-monitor-workspaces
    ];
    extraConfig = lib.fileContents
      "${config.home.homeDirectory}/dotfiles/hypr/hyprland.conf";
  };
}
