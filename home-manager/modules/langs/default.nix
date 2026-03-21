{lib, ...}: {
  imports = lib.collectModules ./. ./default.nix;
}
