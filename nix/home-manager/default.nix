{ inputs, config, lib, pkgs, ... }: {
  imports = [
    ./modules/hyprlock
    ./modules/starship
    ./modules/hyprpanel
    ./modules/nvim
    ./modules/vscode
    ./modules/wezterm
    ./modules/git
    ./modules/zsh
    ./modules/direnv.nix
    ./modules/flutter.nix
    ./modules/fuzzel.nix
    ./modules/yazi.nix
    ./modules/zoxide.nix
    ./modules/environment.nix
    ./modules/hyprland
    ./modules/packages.nix
    ./modules/services.nix
    ./modules/shared-vars.nix
    ./modules/theme.nix
    ./modules/xdg.nix
    ./modules/wallpaper.nix
  ];

  config.wallpaperPath = toString ../../wallpapers/red-nebulae.jpg;
}
