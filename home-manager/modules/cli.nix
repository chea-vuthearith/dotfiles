{pkgs, ...}: {
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  bat.enable = true;
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;
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
