{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    openssl
  ];
  services.ssh-agent = {
    enable = true;
  };
  programs = {
    keychain = {
      enable = true;
      enableZshIntegration = true;
      keys = [
        "id_ed25519"
      ];
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {};
      extraConfig = inputs.secrets.sshConfig;
    };
  };
}
