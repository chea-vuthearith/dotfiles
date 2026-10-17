{inputs, ...}: {
  flake.modules.homeManager.base = {pkgs, ...}: {
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
        settings."*".ForwardAgent = true;
        # Work hosts (Groundup, gina-*); Desktop/Laptop/server go through Tailscale SSH.
        extraConfig = inputs.secrets.sshConfig;
      };
    };
  };
}
