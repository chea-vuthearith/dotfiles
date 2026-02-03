{
  config,
  pkgs,
  username,
  ...
}: {
  users = {
    users.${username} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "input"
        "dialout"
        "video"
        "audio"
        "docker"
        "networkmanager"
        "libvrtd"
        "aria2"
      ];
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
    };
  };
}
