{ pkgs, ... }: {
  imports = [ ../../home.nix ];

  home = { packages = with pkgs; [ cheese bluez bluez-tools virt-manager ]; };
  programs.hyprpanel.settings.bar.layouts."*" = {
    left = [ "notifications" "workspaces" ];
    middle = [ "clock" ];
    right = [
      "custom/screenRecordStatus"
      "battery"
      "systray"
      "hypridle"
      "bluetooth"
      "network"
      "volume"
    ];
  };

  programs.zsh.shellAliases = {
    nsw =
      "git -C ~/dotfiles pull; sudo nixos-rebuild switch --flake ~/dotfiles/nix#laptop --impure";
  };
}
