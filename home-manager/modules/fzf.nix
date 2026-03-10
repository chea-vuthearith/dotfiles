{...}: {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--height 40%"
      "--tmux bottom,40%"
      "--layout reverse"
      "--border top"
    ];
  };
}
