{pkgs, ...}: {
  programs = {
    mpv.enable = true;
    # chromium = {
    #   enable = true;
    #   package = pkgs.brave-origin;
    #   commandLineArgs = [
    #     "--hide-crash-restore-bubble"
    #     "--test-type"
    #     "-enable-features=UseOzonePlatform"
    #     "--ozone-platform=wayland"
    #   ];
    # };
  };
  home.packages = with pkgs; [
    anydesk
    discord
    telegram-desktop
    brave-origin
  ];
}
