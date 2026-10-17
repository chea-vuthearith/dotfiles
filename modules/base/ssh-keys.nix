{config, ...}: let
  inherit (config) username;
in {
  flake.modules.nixos.base = {
    # Keys allowed to log in as $username (replaces hand-edited ~/.ssh/authorized_keys).
    users.users.${username}.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIDUA3TmXCEB9VcvbBtOKKuPYHLGD+FVWE1WB+UvbP53 kuro@nixos"
    ];
  };
}
