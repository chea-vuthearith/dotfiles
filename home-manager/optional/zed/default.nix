{
  pkgs,
  config,
  lib,
  ...
}: {
  home.packages = with pkgs; [zed-editor];
  xdg.configFile."zed/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink (lib.toLocal ./conf/settings.json);
  xdg.configFile."zed/keymap.json".source =
    config.lib.file.mkOutOfStoreSymlink (lib.toLocal ./conf/keymap.json);
}
