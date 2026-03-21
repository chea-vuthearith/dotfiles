{
  inputs,
  lib,
  ...
}: {
  imports =
    [inputs.caelestia-shell.homeManagerModules.default]
    ++ lib.collectModules ./modules;
}
