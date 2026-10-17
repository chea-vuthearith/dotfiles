{
  config,
  osConfig,
  inputs,
  ...
}: {
  home.file."${config.xdg.userDirs.download}/aria2" = {
    source = config.lib.file.mkOutOfStoreSymlink osConfig.services.aria2.settings.dir;
  };
  home.file."${config.home.homeDirectory}/.aria2secret" = {
    text = inputs.secrets.aria2;
  };
}
