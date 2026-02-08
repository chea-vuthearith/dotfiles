{lib}: {
  collectModules = path:
    builtins.filter
    (file: lib.strings.hasSuffix ".nix" (toString file))
    (lib.filesystem.listFilesRecursive path);
}
