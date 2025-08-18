{ inputs, pkgs, ... }: {
  imports = [ ../../home.nix ];

  programs.hyprpanel.settings.bar.layouts."*" = {
    left = [ "notifications" "windowtitle" ];
    middle = [ "media" "workspaces" "clock" ];
    right = [ "systray" "hypridle" "volume" "network" ];
  };

  programs.zsh.shellAliases = {
    nsw =
      "git -C ~/dotfiles pull; sudo nixos-rebuild switch --flake ~/dotfiles/nix#desktop --impure";
    er = ''
      xrandr --output DP-3 --primary && WINEDLLOVERRIDES="dinput8.dll=n,b;d3dcompiler_47=n;dxgi=n,b" umu-run "$HOME/Games/Elden Ring/Game/eldenring.exe"'';
  };

  home.packages = with pkgs; [
    inputs.prismlauncher.packages.${pkgs.system}.prismlauncher
    mono
    umu-launcher
  ];
}
