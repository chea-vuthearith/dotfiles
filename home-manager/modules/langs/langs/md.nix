{pkgs, ...}: {
  home.packages = with pkgs; [
    prettierd
    markdown-toc
    marksman
  ];
}
