{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [ neovim wget dconf dbus zinit];
  programs.zsh.enableGlobalCompInit = false;
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
    nerd-fonts.fira-code
    nerd-fonts.victor-mono
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  time.timeZone = "Asia/Phnom_Penh";
  system.stateVersion = "24.11";
}
