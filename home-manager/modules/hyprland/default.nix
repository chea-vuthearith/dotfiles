{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.file."${config.home.homeDirectory}/.config/hypr/xdph.conf".text = ''
    screencopy {
      allow_token_by_default = true
    }
  '';
  wayland.windowManager.hyprland = {
    enable = true;
    package =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    plugins = [
      inputs.split-monitor-workspaces.packages.${pkgs.stdenv.hostPlatform.system}.split-monitor-workspaces
      pkgs.hyprlandPlugins.hypr-dynamic-cursors
    ];
    extraConfig = "
      source=${./hypr/general.conf}
      source=${./hypr/rules.conf}
      source=${./hypr/keybinds.conf}";
  };
}
