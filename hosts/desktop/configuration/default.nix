{lib, ...}: {
  imports =
    [
      ../../../configuration/global
      ../../../configuration/profiles/desktop.nix
    ]
    ++ lib.collectModules ./overrides;
}
