{
  lib,
  repoDir,
  self,
}: {
  # Every module in `path`: directories (via their default.nix) and *.nix files.
  # Skips `path/default.nix` so a directory's default.nix can collect its siblings.
  collectModules = path:
    builtins.filter
    (file: let
      fileType = builtins.readFileType file;
    in
      fileType
      == "directory"
      || (lib.strings.hasSuffix ".nix" (toString file) && baseNameOf file != "default.nix"))
    (map (name: path + "/${name}") (builtins.attrNames (builtins.readDir path)));

  toLocal = path: builtins.replaceStrings [(toString self)] [repoDir] (toString path);
}
