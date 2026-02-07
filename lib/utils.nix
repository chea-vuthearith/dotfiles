{lib}: {
  collectModules = path: let
    collect = dir: let
      dirEntries = builtins.readDir dir;
      processEntry = name: type:
        if type == "directory"
        then collect (dir + "/${name}")
        else if type == "regular" && lib.strings.hasSuffix ".nix" name
        then [(dir + "/${name}")]
        else [];
    in
      lib.lists.flatten (lib.attrsets.mapAttrsToList processEntry dirEntries);
  in
    collect path;
}
