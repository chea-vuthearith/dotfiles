{ inputs, config, lib, pkgs, ... }: {
  imports = [
    ./modules/direnv.nix
    ./modules/fuzzel.nix
    ./modules/git.nix
    ./modules/hyprlock
    ./modules/starship
    ./modules/hyprpanel
    ./modules/nvim
    ./modules/wezterm
    ./modules/yazi.nix
    ./modules/zoxide.nix
    ./modules/zsh
    ./modules/environment.nix
    ./modules/hyprland
    ./modules/packages.nix
    ./modules/services.nix
    ./modules/shared-vars.nix
    ./modules/theme.nix
    ./modules/xdg.nix
  ];

  config.wallpaperPath = toString ../../wallpapers/red-nebulae.jpg;
}
