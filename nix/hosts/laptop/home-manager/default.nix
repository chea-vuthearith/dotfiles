{ pkgs, ... }: {
  imports = [
    ../../../home-manager
    ./overrides/hyprpanel.nix
    ./overrides/packages.nix
    ./overrides/zsh.nix
  ];
}
