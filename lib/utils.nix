{
  lib,
  repoDir,
  self,
}: {
  collectModules = path:
    builtins.filter
    (file: let
      fileType = builtins.readFileType file;
    in
      fileType == "directory" || lib.strings.hasSuffix ".nix" (toString file))
    (map (name: path + "/${name}") (builtins.attrNames (builtins.readDir path)));

  toLocal = path: builtins.replaceStrings [(toString self)] [repoDir] (toString path);
}
