{
  config,
  pkgs,
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
    plugins = [
      pkgs.hyprlandPlugins.hyprsplit
      pkgs.hyprlandPlugins.hyprtasking
      pkgs.hyprlandPlugins.hypr-dynamic-cursors
    ];
    extraConfig = ''
      source=${lib.toLocal ./hypr/general.conf}
      source=${lib.toLocal ./hypr/keybinds.conf}
      source=${lib.toLocal ./hypr/rules.conf}
    '';
  };
}
