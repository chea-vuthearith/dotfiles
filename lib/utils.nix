{lib}: {
  collectModules = path: let
    _ = builtins.trace "collectModules called with path: ${builtins.toString path}" null;
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
    result = collect path;
    _2 = builtins.trace "collectModules output: ${builtins.toJSON result}" null;
  in
    result;
}
