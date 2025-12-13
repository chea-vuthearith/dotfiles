{ pkgs, config, lib, ... }: {
  programs.hyprlock = {
    enable = true;
    extraConfig = lib.fileContents
      "${config.home.homeDirectory}/dotfiles/hypr/hyprlock.conf";
  };
}
