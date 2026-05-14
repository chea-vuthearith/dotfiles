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

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink (lib.toLocal ./conf);

  programs = {
    neovim = {
      withRuby = true;
      withPython3 = true;
      enable = true;
      viAlias = true;
      defaultEditor = true;
    };
  };
}
