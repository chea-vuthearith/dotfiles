{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    nerd-fonts.victor-mono
  ];
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    systemd.enable = true;
    settings = {
      font-family = config.stylix.fonts.monospace.name;
      font-family-italic = "VictorMono Nerd Font";
      font-family-bold-italic = "VictorMono Nerd Font";
      confirm-close-surface = false;
      mouse-hide-while-typing = true;
      resize-overlay = "never";
    };
  };
}
