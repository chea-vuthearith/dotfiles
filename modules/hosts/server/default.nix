{
  hosts.server.profiles = ["base"];
  # Not yet in the repo: generate on this machine with
  #   nixos-generate-config --show-hardware-config > modules/hosts/server/_hardware-configuration.nix
  # then import ./_hardware-configuration.nix here and drop --impure from nsw.
  flake.modules.nixos.host-server.imports = [/etc/nixos/hardware-configuration.nix];
}
