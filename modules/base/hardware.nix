{...}: {
  flake.modules.nixos.base = {...}: {
    imports = [/etc/nixos/hardware-configuration.nix];
  };
}
