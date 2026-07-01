{pkgs, ...}: {
  home.packages = with pkgs; [
    python3
    ty
    uv
    pyrefly
    pyright
    ruff
  ];
}
