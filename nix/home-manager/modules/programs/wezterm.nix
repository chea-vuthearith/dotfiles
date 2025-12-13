{ pkgs, config, lib, ... }: {
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig =
      lib.fileContents "${config.home.homeDirectory}/dotfiles/wezterm.lua";
  };
}
