{pkgs, ...}: {
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        dpi-aware = "no";
        terminal = "wezterm start --always-new-process";
        layer = "overlay";
        font = "System-ui";
      };
      colors = {
        background = "000000E6";
        border = "000000E6";
        text = "cdd6f4ff";
        prompt = "bac2deff";
        placeholder = "7f849cff";
        input = "cdd6f4ff";
        match = "f38ba8ff";
        selection = "585b70ff";
        selection-text = "cdd6f4ff";
        selection-match = "f38ba8ff";
        counter = "7f849cff";
      };
      border = {
        radius = 17;
        width = 1;
      };
    };
  };
}
