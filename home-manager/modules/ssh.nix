{inputs, ...}: {
  programs = {
    ssh = {
      enable = true;
      extraConfig = inputs.secrets.sshConfig;
    };
  };
}
