{config, ...}:{
  programs.vscode = {
    enable = true;
    profiles.${config.home.userName} = {
      userSettings = builtins.readFile ./settings.json;
      keybindings = builtins.readFile ./keybindings.json;
    };
  };
}
