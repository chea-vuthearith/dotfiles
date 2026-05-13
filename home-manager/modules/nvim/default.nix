{
  pkgs,
  config,
  lib,
  ...
}: {
  home = {
    sessionVariables = {
      PAGER = "less -X -F";
    };
    packages = with pkgs; [
      tree-sitter
    ];

    # file = {
    #   "${config.xdg.configHome}/nvim/lua" = {
    #     source = config.lib.file.mkOutOfStoreSymlink (lib.toLocal ./conf/lua);
    #     recursive = true;
    #   }; # lazy vim is self managed
    #
    #   "${config.xdg.configHome}/nvim/lazy-lock.json".source =
    #     config.lib.file.mkOutOfStoreSymlink (lib.toLocal ./conf/lazy-lock.json);
    #
    #   "${config.xdg.configHome}/nvim/lazyvim.json".source =
    #     config.lib.file.mkOutOfStoreSymlink (lib.toLocal ./conf/lazyvim.json);
    #
    #   "${config.xdg.configHome}/nvim/stylua.toml".source =
    #     config.lib.file.mkOutOfStoreSymlink (lib.toLocal ./conf/stylua.toml);
    # };
    #
  };

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink (lib.toLocal ./conf);

  programs = {
    neovim = {
      withRuby = true;
      withPython3 = true;
      enable = true;
      viAlias = true;
      defaultEditor = true;
      # initLua = ''
      #   require("config.lazy")
      # '';
    };
  };
}
