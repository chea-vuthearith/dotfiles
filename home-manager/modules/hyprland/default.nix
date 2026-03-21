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
      # inputs.split-monitor-workspaces.packages.${pkgs.stdenv.hostPlatform.system}.split-monitor-workspaces
      # inputs.hypr-dynamic-cursors.packages.${pkgs.stdenv.hostPlatform.system}.hypr-dynamic-cursors
      # pkgs.hyprlandPlugins.hyprspace
    ];
    extraConfig = "
      source=${./hypr/general.conf}
      source=${./hypr/rules.conf}
      source=${./hypr/keybinds.conf}";
  };
}
