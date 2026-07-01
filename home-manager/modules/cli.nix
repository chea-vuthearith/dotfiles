{
  pkgs,
  lib,
  ...
}: {
  programs = {
    atuin = {
      enable = true;
      settings = {
        filter_mode_shell_up_key_binding = "session";
        search_mode = "fuzzy";
        style = "full";
        show_preview = true;
      };
    };
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
    zsh = {
      initContent = lib.mkOrder 1600 ''
        bindkey -M vicmd -r 'j'
        bindkey -M vicmd -r 'k'
      '';
      shellAliases = {
        cat = "bat";
        ls = "eza --icons";
        lt = "eza --tree --icons";
      };
    };
  };
  home.packages = with pkgs; [
    terraform
    google-cloud-sdk
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
