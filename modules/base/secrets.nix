{inputs, ...}: {
  # sops-nix: secrets.yaml in the private `secrets` flake, decrypted at activation to /run/secrets.
  # Features declare their own `sops.secrets.<name>` next to the consumer.
  # New host: sudo mkdir -p /var/lib/sops-nix && sudo age-keygen -o /var/lib/sops-nix/key.txt
  #   then add `sudo age-keygen -y /var/lib/sops-nix/key.txt` to .sops.yaml and `sops updatekeys secrets.yaml`.
  flake.modules.nixos.base = {...}: {
    imports = [inputs.sops-nix.nixosModules.sops];
    sops = {
      defaultSopsFile = inputs.secrets.sopsFile;
      age = {
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
        sshKeyPaths = []; # no OpenSSH server, so no host ssh keys
      };
      gnupg.sshKeyPaths = [];
    };
  };
  # Editing: `sops secrets.yaml` in the secrets repo, key in ~/.config/sops/age/keys.txt (backed up in Bitwarden).
  flake.modules.homeManager.base = {pkgs, ...}: {
    home.packages = [pkgs.sops pkgs.age];
  };
}
