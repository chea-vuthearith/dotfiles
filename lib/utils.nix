{lib}: {
  collectModules = path:
    builtins.filter
    (file: let
      fileType = builtins.readFileType file;
    in
      fileType == "directory" || lib.strings.hasSuffix ".nix" (toString file))
    (map (name: path + "/${name}") (builtins.attrNames (builtins.readDir path)));
}
