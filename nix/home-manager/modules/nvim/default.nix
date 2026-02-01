{ pkgs, config, ... }: {
  home.packages = with pkgs; [ neovim ];
  programs.zsh.shellAliases = { vi = "nvim"; };
  home.file = {
    ".config/nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles/nix/home-manager/modules/nvim/conf"; # lazy vim is self managed
    };
  };

  programs.neovide = {
    enable = true;
    settings = {
      font = {
        normal = [ "FiraCode Nerd Font" "Noto Sans Khmer" ];
        italic = [ "VictorMono Nerd Font" ];
        size = 12;
      };
    };
  };
}
