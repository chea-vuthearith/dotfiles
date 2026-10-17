{
  lib,
  config,
  ...
}: {
  options = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "kuro";
      description = "The one user on every host.";
    };
    repoDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/${config.username}/dotfiles";
      description = "Checkout of this repo; target of out-of-store symlinks (lib.toLocal) for hot reload.";
    };
  };
}
