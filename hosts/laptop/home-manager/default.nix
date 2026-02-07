{lib, ...}: {
  imports =
    [
      ../../../home-manager
    ]
    ++ lib.collectModules ./overrides;
}
