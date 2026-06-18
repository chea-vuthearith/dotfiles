{pkgs, ...}: {
  home.packages = with pkgs; [
    mono
    umu-launcher
    steam
    # rpcs3
    # SDL2
  ];
}
