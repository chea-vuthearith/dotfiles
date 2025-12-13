{ pkgs, config, ... }: {
  home.file = {
    ".config/nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles/nvim";
    };
  };
  programs.neovim = {
    enable = true;
    viAlias = true;
    extraLuaPackages = ps: [ ps.magick ];
    defaultEditor = true;
  };
}
