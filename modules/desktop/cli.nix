{...}: {
  flake.modules.homeManager.desktop = {
    pkgs,
    lib,
    ...
  }: {
    programs.zsh = {
      initContent = lib.mkOrder 1600 ''
        bindkey -M vicmd -r 'j'
        bindkey -M vicmd -r 'k'
      '';
      shellAliases.gt = "nvim ~/code/work/groundup/todo.*";
    };
    home.packages = with pkgs; [
      terraform
      google-cloud-sdk
      swappy
      playerctl
      wf-recorder
      tesseract
      ffmpeg
      hyprpicker
      pavucontrol
      brightnessctl
      imagemagick
      newt
      grim
      slurp
      wl-clipboard
    ];
  };
}
