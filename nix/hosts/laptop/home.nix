{ pkgs, ... }: {
  imports = [ ../../home.nix ];

  home.packages = with pkgs; [ droidcam ];

  programs.hyprpanel.settings = {
    layout."bar.layouts"."*" = {
      left = [ "notifications" "windowtitle" ];
      middle = [ "media" "workspaces" "clock" "battery" ];
      right = [ "systray" "hypridle" "volume" "network" ];
    };
  };

  programs.zsh.shellAliases = {
    nsw =
      "cd ~/dotfiles && git pull; sudo nixos-rebuild switch --flake ~/dotfiles/nix#laptop --impure; cd -";
  };
}
