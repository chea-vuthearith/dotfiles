{ inputs, pkgs, config, ... }: {
  imports = [
    ../../../home-manager/home.nix
    ./overrides/games.nix
    ./overrides/hyprpanel.nix
    ./overrides/zsh.nix
  ];

}
