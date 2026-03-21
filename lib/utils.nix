{lib}: {
  collectModules = {
    path,
    callerFile ? null,
  }:
    builtins.filter
    (file: let
      fileType = builtins.readFileType file;
    in
      (callerFile == null || file != callerFile)
      && (fileType == "directory" || lib.strings.hasSuffix ".nix" (toString file)))
    (map (name: path + "/${name}") (builtins.attrNames (builtins.readDir path)));
}
