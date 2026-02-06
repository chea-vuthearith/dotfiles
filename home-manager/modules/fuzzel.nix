{pkgs, ...}: {
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        dpi-aware = "no";
        terminal = "wezterm start --always-new-process";
        layer = "overlay";
      };
      border = {
        radius = 17;
        width = 1;
      };
    };
  };
}
