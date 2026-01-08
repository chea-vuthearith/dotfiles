{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [ neovim wget dconf dbus zinit ];
  programs.zsh.enableGlobalCompInit = false;
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
    nerd-fonts.fira-code
    nerd-fonts.victor-mono
  ];
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    max-jobs = "auto";
    cores = 0;
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  time.timeZone = "Asia/Phnom_Penh";
  system.stateVersion = "24.11";
}
