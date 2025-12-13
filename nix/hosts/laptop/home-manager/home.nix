{ pkgs, ... }: {
  imports = [
    ../../../home-manager/home.nix
    ./overrides/hyprpanel.nix
    ./overrides/packages.nix
    ./overrides/zsh.nix
  ];
}
