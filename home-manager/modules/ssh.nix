{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    openssl
  ];
  programs = {
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."*" = {};
      extraConfig = inputs.secrets.sshConfig;
    };
  };
}
