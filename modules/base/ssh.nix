{
  flake.modules.homeManager.base = {
    pkgs,
    osConfig,
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
        extraFlags = [
          "--quiet"
          "--immediate"
        ];
        keys = [
          "id_ed25519"
        ];
      };

      ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings."*" = {};
        # Host aliases, decrypted by sops-nix (modules/base/sops.nix).
        includes = [osConfig.sops.secrets.ssh-config.path];
      };
    };
  };
}
