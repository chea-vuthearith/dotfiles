{pkgs, ...}: {
  home.packages = with pkgs; [mono umu-launcher rpcs3];
}
