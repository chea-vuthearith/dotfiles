{
  pkgs,
  lib,
  config,
  ...
}: {
  home.packages = [pkgs.herdr];

  programs.zsh.shellAliases.h = "herdr";

  programs.zsh.initContent = lib.mkOrder 1500 ''
    hr() { herdr --remote "$@" }
    compdef hr=ssh
  '';

  xdg.configFile."herdr/config.toml" = {
    source = config.lib.file.mkOutOfStoreSymlink (lib.toLocal ./config.toml);
  };

  xdg.configFile."herdr/plugins/config/freethinkel.worktree-hooks/config.yml" = {
    source = config.lib.file.mkOutOfStoreSymlink (lib.toLocal ./plugins/freethinkel.worktree-hooks/config.yml);
  };
}
