{pkgs, ...}: {
  programs = {
    mpv.enable = true;
  };
  home.packages = with pkgs; [
    anydesk
    discord
    telegram-desktop
    brave-origin
  ];
}
