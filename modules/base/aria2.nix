{config, ...}: let
  inherit (config) username;
in {
  flake.modules.homeManager.base = {pkgs, ...}: {
    home.packages = [pkgs.aria2];
  };
  flake.modules.nixos.desktop = {config, ...}: {
    # 0440 group aria2: the daemon reads it via LoadCredential, kuro (in aria2) for RPC clients.
    sops.secrets.aria2-rpc = {
      group = "aria2";
      mode = "0440";
    };
    services.aria2 = {
      enable = true;
      settings = {
        enable-rpc = true;
        resume = true;
      };
      rpcSecretFile = config.sops.secrets.aria2-rpc.path;
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
  };
}
