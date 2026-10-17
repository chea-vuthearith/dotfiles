# Imported by every host.
{lib, ...}: {
  imports = lib.collectModules ./.;
}
