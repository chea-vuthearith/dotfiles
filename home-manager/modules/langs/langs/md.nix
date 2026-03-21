{pkgs, ...}: {
  home.packages = with pkgs; [
    markdown-toc
    markdownlint-cli2
    marksman
  ];
}
