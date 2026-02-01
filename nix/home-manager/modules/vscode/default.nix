{ config, ... }: {
  home.file = {
    ".config/Code/User/settings.json" = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles/nix/home-manager/modules/vscode/settings.json";
    };
    ".config/Code/User/keybindings.json" = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles/nix/home-manager/modules/vscode/keybindings.json";
    };
  };
  programs.vscode = { enable = true; };
}
