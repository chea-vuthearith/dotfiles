{
  config,
  inputs,
  ...
}: let
  inherit (config) username;
in {
  flake.modules.homeManager.base = {pkgs, ...}: {
    home.packages = [pkgs.aria2];
  };
  flake.modules.nixos.desktop = {...}: {
    services.aria2 = {
      enable = true;
      settings = {
        enable-rpc = true;
        resume = true;
      };
      rpcSecretFile = "/home/${username}/.aria2secret";
    };
    users.users.${username}.extraGroups = ["aria2"];
  };
  flake.modules.homeManager.desktop = {
    config,
    osConfig,
    ...
  }: {
    home.file."${config.xdg.userDirs.download}/aria2" = {
      source = config.lib.file.mkOutOfStoreSymlink osConfig.services.aria2.settings.dir;
    };
    home.file."${config.home.homeDirectory}/.aria2secret" = {
      text = inputs.secrets.aria2;
    };
  };
}
