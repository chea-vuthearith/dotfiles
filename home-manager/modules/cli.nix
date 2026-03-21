{pkgs, ...}: {
  programs = {
    bat.enable = true;
    fzf = {
      enable = true;
      enableZshIntegration = true;
      tmux.enableShellIntegration = true;
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    zsh.shellAliases = {
      cat = "bat";
      ls = "eza --icons";
      lt = "eza --tree --icons";
    };
  };
  home.packages = with pkgs; [
    eza
    fd
    ripgrep
    lsof
    zip
    unzip
    unrar
    bottom
    swappy
    aria2
    jq
    xh
    magic-wormhole
    playerctl
    wf-recorder
    tesseract
    ffmpeg
    hyprpicker
    pavucontrol
    brightnessctl
    imagemagick
    newt
    dragon-drop
    grim
    slurp
    wl-clipboard
  ];
}
