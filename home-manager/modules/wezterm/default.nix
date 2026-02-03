{
  pkgs,
  config,
  lib,
  ...
}: {
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = builtins.readFile ./wezterm.lua;
  };
}
