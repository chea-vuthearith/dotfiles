{pkgs, ...}: {
  home.packages = with pkgs; [
    ueberzugpp
  ];
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    systemd.enable = true;
    settings = {
      confirm-close-surface = false;
      mouse-hide-while-typing = true;
      resize-overlay = "never";
    };
  };
}
