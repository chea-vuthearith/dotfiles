{pkgs, ...}: {
  home.packages = with pkgs; [
    prettierd
    markdown-toc
    marksman
    mermaid-cli
    markdownlint-cli2
    tectonic
    ghostscript
  ];
}
