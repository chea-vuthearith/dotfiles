{ pkgs, lib, config, ... }: {
  home.packages = [ pkgs.herdr ];
  xdg.configFile."herdr/config.toml" = {
    source = config.lib.file.mkOutOfStoreSymlink (lib.toLocal ./config.toml);
  };
}
