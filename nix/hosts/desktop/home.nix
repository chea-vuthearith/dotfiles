{ ... }: {
  imports = [ ../../home.nix ];

  programs.hyprpanel.settings = {
    layout."bar.layouts"."*" = {
      left = [ "notifications" "windowtitle" ];
      middle = [ "media" "workspaces" "clock" ];
      right = [ "systray" "hypridle" "volume" "network" ];
    };
  };

  programs.zsh.shellAliases = {
    nsw =
      "cd ~/dotfiles && git pull; sudo nixos-rebuild switch --flake ~/dotfiles/nix#desktop --impure; cd -";
  };
}
