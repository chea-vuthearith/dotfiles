{lib, ...}: {
  imports =
    [
      ../../../configuration/global
    ]
    ++ lib.collectModules ./overrides;
}
