{pkgs, ...}: {
  home.packages = with pkgs; [
    python3
    uv
    pyrefly
    pyright
    ruff
  ];
}
