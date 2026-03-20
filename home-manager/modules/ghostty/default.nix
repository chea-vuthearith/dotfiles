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
      custom-shader = ./starfield.glsl;
      notify-on-command-finish = "always";
      notify-on-command-finish-action = "no-bell,notify";
      window-padding-x = "5";
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
