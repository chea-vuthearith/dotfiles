{inputs, ...}: {
  programs = {
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."*" = {};
      extraConfig = inputs.secrets.sshConfig;
    };
  };
}
