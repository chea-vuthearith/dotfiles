{ config, pkgs, ... }: {
  users = {
    users.kuro = {
      isNormalUser = true;
      extraGroups =
        [ "wheel" "video" "audio" "docker" "networkmanager" "libvrtd" "aria2" ];
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
    };
  };
}
