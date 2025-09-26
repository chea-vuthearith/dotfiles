{ inputs, pkgs, config, ... }: {
  imports = [ ../../home.nix ];

  programs.hyprpanel.settings.bar.layouts."*" = {
    left = [ "notifications" "workspaces" ];
    middle = [ "clock" ];
    right =
      [ "custom/screenRecordStatus" "systray" "hypridle" "network" "volume" ];
  };

  programs.zsh.shellAliases = {
    nsw =
      "git -C ~/dotfiles pull; sudo nixos-rebuild switch --flake ~/dotfiles/nix#desktop --impure";
  };

  xdg.desktopEntries = {
    "Elden Ring" = {
      name = "Elden Ring";
      exec = ''
        sh -c "xrandr --output DP-3 --primary && WINEDLLOVERRIDES='dinput8.dll=n,b;d3dcompiler_47=n;dxgi=n,b' umu-run '${config.home.homeDirectory}/Games/Elden Ring/Game/eldenring.exe'"'';
      categories = [ "Game" ];
      icon = "/home/kuro/Games/Elden Ring/Game/EasyAntiCheat/splashscreen.png";
    };
  };

  home.packages = with pkgs; [
    inputs.prismlauncher.packages.${pkgs.system}.prismlauncher
    mono
    umu-launcher
  ];
}
