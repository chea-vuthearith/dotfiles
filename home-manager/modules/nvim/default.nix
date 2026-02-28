{
  pkgs,
  config,
  inputs,
  ...
}: let
  nvimConfDir = "${config.home.homeDirectory}/dotfiles/home-manager/modules/nvim/conf";
in {
  home = {
    sessionVariables = {
      PAGER = "less -X -F";
    };
    packages = import ./extra-packages.nix {inherit pkgs;};

    file = {
      "${config.xdg.configHome}/nvim/lua" = {
        source = config.lib.file.mkOutOfStoreSymlink "${nvimConfDir}/lua";
        recursive = true;
      }; # lazy vim is self managed

      "${config.xdg.configHome}/nvim/lazy-lock.json".source =
        config.lib.file.mkOutOfStoreSymlink "${nvimConfDir}/lazy-lock.json";

      "${config.xdg.configHome}/nvim/lazyvim.json".source =
        config.lib.file.mkOutOfStoreSymlink "${nvimConfDir}/lazyvim.json";

      "${config.xdg.configHome}/nvim/stylua.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${nvimConfDir}/stylua.toml";
    };
  };

  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"]; # for nixd lsp

  programs = {
    helix = {
      enable = true;
    };
    neovim = {
      enable = true;
      viAlias = true;
      defaultEditor = true;
      initLua = ''
        require("config.lazy")
      '';
    };
  };
}
