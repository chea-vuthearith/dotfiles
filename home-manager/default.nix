{
  inputs,
  lib,
  ...
}: {
  imports =
    [
      inputs.dms.homeModules.default
      inputs.dms-plugin-registry.homeModules.default
    ]
    ++ lib.collectModules ./modules;
}
