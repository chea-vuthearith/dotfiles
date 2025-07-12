{ inputs, pkgs, ... }: {
  imports = [ ../../home.nix ];

  programs.hyprpanel.settings = {
    layout."bar.layouts"."*" = {
      left = [ "notifications" "windowtitle" ];
      middle = [ "media" "workspaces" "clock" ];
      right = [ "systray" "hypridle" "volume" "network" ];
    };
  };

  wayland.windowManager.hyprland.plugins = [
    inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces

  ];

  programs.zsh.shellAliases = {
    nsw =
      "git -C ~/dotfiles pull; sudo nixos-rebuild switch --flake ~/dotfiles/nix#desktop --impure";
  };
}
