{inputs, ...}: {
  programs.ssh.extraConfig = builtins.readFile inputs.secrets.sshConfig;
}
