{config, ...}: let
  inherit (config) username;
in {
  flake.modules.nixos.base = {pkgs, ...}: {
    security.sudo = {
      enable = true;
      extraConfig = ''
        Defaults env_keep+=SSH_AUTH_SOCK
      '';
    };
    # Features add their own groups (networking, docker, aria2, ...).
    users.users.${username} = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
    };
  };
}
