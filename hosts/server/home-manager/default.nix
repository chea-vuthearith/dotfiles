{lib, ...}: {
  imports =
    [
      ../../../home-manager/global
    ]
    ++ lib.collectModules ./overrides;
}
