{
  config,
  inputs,
  ...
}: let
  inherit (config) username;
in {
  flake.modules.nixos.base = {
    imports = [inputs.sops-nix.nixosModules.sops];

    # Encrypted values live in secrets/secrets.yaml; recipients in .sops.yaml.
    # Edit: SOPS_AGE_KEY=$(ssh-to-age -private-key -i ~/.ssh/id_ed25519) sops secrets/secrets.yaml
    sops = {
      defaultSopsFile = ../../secrets/secrets.yaml;
      # Decrypt with the host key where it is a recipient, else with the user key,
      # which is a recipient for every host.
      age.sshKeyPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
        "/home/${username}/.ssh/id_ed25519"
      ];
      gnupg.sshKeyPaths = [];

      secrets.ssh-config.owner = username;
    };
  };
}
