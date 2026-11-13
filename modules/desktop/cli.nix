{...}: {
  flake.modules.homeManager.desktop = {
    pkgs,
    lib,
    ...
  }: {
    programs.zsh = {
      initContent = lib.mkMerge [
        # Shells under a herdr server that was started from SSH (or before Hyprland)
        # lack the graphical session env, which breaks xdg-open, wl-copy, dragon-drop.
        # Pull it from the systemd user manager, which Hyprland populates.
        (lib.mkOrder 500 ''
          if [[ -z $WAYLAND_DISPLAY ]]; then
            export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$UID}"
            for _kv in ''${(f)"$(systemctl --user show-environment 2>/dev/null)"}; do
              [[ $_kv == (WAYLAND_DISPLAY|DISPLAY|XDG_CURRENT_DESKTOP|HYPRLAND_INSTANCE_SIGNATURE)=* ]] && export "$_kv"
            done
            unset _kv
          fi
        '')
        (lib.mkOrder 1600 ''
          bindkey -M vicmd -r 'j'
          bindkey -M vicmd -r 'k'
        '')
      ];
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
