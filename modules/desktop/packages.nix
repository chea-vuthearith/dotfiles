{...}: {
  flake.modules.homeManager.desktop = {pkgs, ...}: {
    programs = {
      mpv.enable = true;
    };
    home.packages = with pkgs; [
      discord
      telegram-desktop
      brave-origin
      libreoffice
    ];
  };
}
