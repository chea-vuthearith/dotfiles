{config, ...}: let
  inherit (config) username;
in {
  flake.modules.nixos.host-server = {pkgs, ...}: {
    security.sudo = {
      enable = true;
      extraConfig = ''
        Defaults env_keep+=SSH_AUTH_SOCK
      '';
    };
    users.users.${username} = {
      isNormalUser = true;
      extraGroups = ["wheel" "docker" "networkmanager"];
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
    };
  };
}
