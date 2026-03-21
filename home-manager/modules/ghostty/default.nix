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
      window-padding-x = "5";
      notify-on-command-finish = "unfocused";
      notify-on-command-finish-action = "bell,notify";
      notify-on-command-finish-after = "4s";
      window-padding-y = "0";
      shell-integration-features = "ssh-env, title";
      font-family = config.stylix.fonts.monospace.name;
      font-family-italic = "VictorMono Nerd Font";
      font-family-bold-italic = "VictorMono Nerd Font";
      confirm-close-surface = false;
      mouse-hide-while-typing = true;
      resize-overlay = "never";
    };
  };
}
