{
  flake.modules.nixos.desktop = {config, ...}: {
    # Root-only; the aria2 unit reads it via LoadCredential.
    sops.secrets.aria2 = {};

    services.aria2 = {
      enable = true;
      settings = {
        enable-rpc = true;
        resume = true;
      };
      rpcSecretFile = config.sops.secrets.aria2.path;
    };
  };
  flake.modules.homeManager.desktop = {
    config,
    osConfig,
    ...
  }: {
    home.file."${config.xdg.userDirs.download}/aria2" = {
      source = config.lib.file.mkOutOfStoreSymlink osConfig.services.aria2.settings.dir;
    };
  };
}
