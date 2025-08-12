{ inputs, pkgs, ... }: {
  imports = [ ../../home.nix ];

  programs.hyprpanel.settings.bar.layouts."*" = {
    left = [ "notifications" "windowtitle" ];
    middle = [ "media" "workspaces" "clock" ];
    right = [ "systray" "hypridle" "volume" "network" ];
  };

  wayland.windowManager.hyprland.plugins = [
    inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces

  ];

  programs.zsh.shellAliases = {
    nsw =
      "git -C ~/dotfiles pull; sudo nixos-rebuild switch --flake ~/dotfiles/nix#desktop --impure";
    eldenring = ''
      WINEDLLOVERRIDES="dinput8.dll=n,b" umu-run "$HOME/Games/Elden Ring/Game/eldenring.exe"'';
  };

  home.packages = with pkgs; [
    inputs.prismlauncher.packages.${pkgs.system}.prismlauncher
    mono
    umu-launcher
  ];

  wayland.windowManager.hyprland.systemd.extraCommands =
    [ "xrandr --output DP-3 --primary" ];
}
