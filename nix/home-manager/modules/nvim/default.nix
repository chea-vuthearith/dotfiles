{ pkgs, config, lib, ... }: {
  home.file = {
    ".config/nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles/nix/home-manager/modules/nvim/conf"; # lazy vim is self managed
    };
  };
  programs.neovim = {
    enable = true;
    viAlias = true;
    extraLuaPackages = ps: [ ps.magick ];
    defaultEditor = true;
  };
}
