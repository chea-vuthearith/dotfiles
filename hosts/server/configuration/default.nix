{
  inputs,
  username,
  lib,
  ...
}: {
  imports =
    [
      inputs.home-manager.nixosModules.default
      ../../configuration/modules/hm.nix
      ../../configuration/modules/networking.nix
      ../../configuration/modules/ssh.nix
      ../../configuration/modules/storage.nix
      ../../configuration/modules/virtualization.nix
      ../../configuration/modules/cache-host.nix
      /etc/nixos/hardware-configuration.nix
    ]
    ++ lib.collectModules ./overrides;

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users.${username} = import ../home-manager;
  };
}
