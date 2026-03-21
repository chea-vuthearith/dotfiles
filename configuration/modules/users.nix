{
  pkgs,
  username,
  ...
}: {
  security.sudo = {
    enable = true;
    extraConfig = ''
      Defaults env_keep += "SSH_AUTH_SOCK"
    '';
  };
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
        "libvirtd"
        "aria2"
        "kvm"
        "adbusers"
      ];
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
    };
  };
}
