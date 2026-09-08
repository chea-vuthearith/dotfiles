{
  pkgs,
  username,
  ...
}: {
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
}
