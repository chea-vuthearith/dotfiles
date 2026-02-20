{...}: {
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    attachExistingSession = true;
    exitShellOnExit = true;
    extraConfig = '''';
    settings = {
      mouse_mode = false;
      ui.pane_frames.rounded_corners = true;
      keybinds = {
        normal = [
          {
            bind = {
              _args = ["Ctrl h"];
              _children = [{MoveFocus = "Left";}];
            };
          }
          {
            bind = {
              _args = ["Ctrl j"];
              _children = [{MoveFocus = "Down";}];
            };
          }
          {
            bind = {
              _args = ["Ctrl k"];
              _children = [{MoveFocus = "Up";}];
            };
          }
          {
            bind = {
              _args = ["Ctrl l"];
              _children = [{MoveFocus = "Right";}];
            };
          }
        ];
      };
    };
  };
}
