{ inputs, config, lib, pkgs, ... }: {
  imports = [
    ./modules/programs/direnv.nix
    ./modules/programs/fuzzel.nix
    ./modules/programs/git.nix
    ./modules/programs/hyprlock
    ./modules/programs/starship
    ./modules/programs/hyprpanel
    ./modules/programs/nvim
    ./modules/programs/wezterm
    ./modules/programs/yazi.nix
    ./modules/programs/zoxide.nix
    ./modules/programs/zsh
    ./modules/environment.nix
    ./modules/hyprland
    ./modules/packages.nix
    ./modules/services.nix
    ./modules/shared-vars.nix
    ./modules/theme.nix
    ./modules/xdg.nix
  ];

  config.wallpaperPath = ./red-nebulae.jpg;
}
