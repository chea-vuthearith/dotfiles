{ pkgs, config, ... }: {
  home.file = {
    "${config.xdg.configHome}/nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles/nix/home-manager/modules/programs/nvim/conf";
    };
  };
  programs.neovim = {
    enable = true;
    viAlias = true;
    extraLuaPackages = ps: [ ps.magick ];
    defaultEditor = true;
  };
}
