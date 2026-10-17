{lib, ...}: {
  imports =
    [
      ../../../home-manager/global
      ../../../home-manager/profiles/desktop.nix
    ]
    ++ lib.collectModules ./overrides;
}
