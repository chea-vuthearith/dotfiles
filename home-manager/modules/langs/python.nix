{pkgs, ...}: {
  home.packages = with pkgs; [
    python3
    uv
    pyright
    ruff
  ];
}
