{lib}: {
  collectModules = path: let
    files = lib.filesystem.listFilesRecursive path;
    nixFiles = builtins.filter (f: lib.strings.hasSuffix ".nix" (builtins.toString f)) files;
  in
    nixFiles;
}
