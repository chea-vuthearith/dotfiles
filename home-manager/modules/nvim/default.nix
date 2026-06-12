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
  };

  xdg.configFile."nvim/nvim-pack-lock.json".source = config.lib.file.mkOutOfStoreSymlink (lib.toLocal ./conf/nvim-pack-lock.json);
  xdg.configFile."nvim/lua".source = config.lib.file.mkOutOfStoreSymlink (lib.toLocal ./conf/lua);

  programs = {
    neovim = {
      withRuby = true;
      withPython3 = true;
      enable = true;
      viAlias = true;
      defaultEditor = true;
      initLua = builtins.readFile ./conf/init.lua;
    };
  };
}
