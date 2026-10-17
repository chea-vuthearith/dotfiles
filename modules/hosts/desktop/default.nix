{
  hosts.desktop.profiles = ["base" "desktop"];
  # Not yet in the repo: generate on this machine with
  #   nixos-generate-config --show-hardware-config > modules/hosts/desktop/_hardware-configuration.nix
  # then import ./_hardware-configuration.nix here and drop --impure from nsw.
  flake.modules.nixos.host-desktop.imports = [/etc/nixos/hardware-configuration.nix];
}
