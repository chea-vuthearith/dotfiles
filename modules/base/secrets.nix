{inputs, ...}: {
  # sops-nix: secrets.yaml in the private `secrets` flake, decrypted at activation to /run/secrets.
  # Features declare their own `sops.secrets.<name>` next to the consumer.
  # One shared age key (the admin key, backed up in Bitwarden) on every host at /var/lib/sops-nix/key.txt:
  #   sudo install -D -m600 keys.txt /var/lib/sops-nix/key.txt
  # Bootstrap stub (`inputs.secrets.bootstrap = true`, scripts/bootstrap.sh): secret paths stay
  # declared so consumers evaluate, but nothing is validated or decrypted; consumers start once
  # a real `nsw` runs.
  flake.modules.nixos.base = {lib, ...}: let
    bootstrap = inputs.secrets.bootstrap or false;
  in {
    imports = [inputs.sops-nix.nixosModules.sops];
    sops = {
      defaultSopsFile = inputs.secrets.sopsFile;
      validateSopsFiles = !bootstrap;
      age = {
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = false; # a generated key matches no recipient; fail loudly instead
        sshKeyPaths = []; # no OpenSSH server, so no host ssh keys
      };
      gnupg.sshKeyPaths = [];
    };
    system.activationScripts.setupSecrets = lib.mkIf bootstrap (lib.mkForce "");
  };
  # Editing: `sops secrets.yaml` in the secrets repo, key in ~/.config/sops/age/keys.txt (backed up in Bitwarden).
  flake.modules.homeManager.base = {pkgs, ...}: {
    home.packages = [pkgs.sops pkgs.age];
  };
}
