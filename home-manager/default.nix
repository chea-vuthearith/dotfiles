{lib, ...}: {
  imports =
    lib.collectModules
    ./modules;
  # hello world
}
