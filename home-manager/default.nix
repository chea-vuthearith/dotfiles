{lib, ...}: {
  imports =
    lib.collectModules
    ./modules;
}
