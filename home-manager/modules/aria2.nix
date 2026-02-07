{
  config,
  osConfig,
  ...
}: {
  home.file."${config.xdg.userDirs.download}/aria2" = {
    source = config.lib.file.mkOutOfStoreSymlink osConfig.services.aria2.settings.dir;
  };
}
