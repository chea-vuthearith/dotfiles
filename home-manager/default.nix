{
  inputs,
  lib,
  ...
}: {
  imports =
    [inputs.noctalia.homeModules.default]
    ++ lib.collectModules ./modules;
}
