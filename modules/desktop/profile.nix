# Third-party modules the desktop profile needs.
{inputs, ...}: {
  flake.modules.nixos.desktop.imports = [
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.stylix.nixosModules.stylix
  ];
  flake.modules.homeManager.desktop.imports = [
    inputs.dms.homeModules.default
    inputs.dms-plugin-registry.homeModules.default
  ];
}
