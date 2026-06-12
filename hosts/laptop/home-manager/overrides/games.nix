{pkgs, ...}: {
  home.packages = with pkgs; [
    umu-launcher
  ];
}
