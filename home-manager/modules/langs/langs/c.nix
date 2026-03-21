{pkgs, ...}: {
  home.packages = with pkgs; [
    gcc
    libgcc
    gnumake
    gnused
  ];
}
