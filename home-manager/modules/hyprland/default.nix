{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  home.file = {
    "${config.xdg.configHome}/hypr/xdph.conf".text = ''
      screencopy {
        allow_token_by_default = true
      }
    '';
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    plugins = [
      inputs.hyprsplit.packages.${pkgs.stdenv.hostPlatform.system}.hyprsplit
      inputs.hyprtasking.packages.${pkgs.stdenv.hostPlatform.system}.hyprtasking
      inputs.hypr-dynamic-cursors.packages.${pkgs.stdenv.hostPlatform.system}.hypr-dynamic-cursors
    ];
    extraConfig = ''
      source=${lib.toLocal ./hypr/general.conf}
      source=${lib.toLocal ./hypr/keybinds.conf}
      source=${lib.toLocal ./hypr/rules.conf}
    '';
  };
}
