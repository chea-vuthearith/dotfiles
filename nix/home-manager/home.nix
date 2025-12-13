{ inputs, config, lib, pkgs, ... }: {
  imports = [
    ./modules/programs/direnv.nix
    ./modules/programs/fuzzel.nix
    ./modules/programs/git.nix
    ./modules/programs/hyprlock.nix
    ./modules/programs/hyprpanel.nix
    ./modules/programs/neovim.nix
    ./modules/programs/wezterm.nix
    ./modules/programs/yazi.nix
    ./modules/programs/zoxide.nix
    ./modules/programs/zsh.nix
    ./modules/environment.nix
    ./modules/hyprland.nix
    ./modules/packages.nix
    ./modules/services.nix
    ./modules/shared-vars.nix
    ./modules/theme.nix
    ./modules/xdg.nix
  ];

  config.wallpaperPath =
    "${config.home.homeDirectory}/dotfiles/wallpaper/red-nebulae.jpg";
}
