{pkgs, ...}: {
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        dpi-aware = "no";
        layer = "overlay";
      };
      border = {
        radius = 17;
        width = 1;
      };
    };
  };
}
