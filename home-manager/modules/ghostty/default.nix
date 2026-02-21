{...}: {
  home.sessionVariables.TERMCMD = "ghostty -e";
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    systemd.enable = true;
    settings = {
      mouse-hide-while-typing = true;
      resize-overlay = "never";
    };
  };
}
