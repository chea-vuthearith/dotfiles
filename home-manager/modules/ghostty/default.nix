{...}: {
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    systemd.enable = true;
  };
}
