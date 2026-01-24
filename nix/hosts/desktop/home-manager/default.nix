{ inputs, pkgs, config, ... }: {
  imports = [
    ../../../home-manager
    ./overrides/games.nix
    ./overrides/hyprpanel.nix
    ./overrides/zsh.nix
    ./overrides/cache-host.nix
  ];

}
