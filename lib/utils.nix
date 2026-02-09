{lib}: {
  # collectModules: import any .nix files that live directly in `path`
  # plus recursively import only files named `default.nix` anywhere under `path`.
  collectModules = path: let
    all = lib.filesystem.listFilesRecursive path;
    isDefault = f: builtins.match ".*/default.nix$" (toString f) != null;
    prefix = (toString path) + "/";
    rel = f: builtins.substring (builtins.stringLength prefix) (builtins.stringLength (toString f) - builtins.stringLength prefix) (toString f);
    isTop = f: (lib.strings.hasSuffix ".nix" (toString f)) && (! lib.strings.containsStr "/" (rel f));
    chosen =
      builtins.filter (
        f:
          (lib.strings.hasSuffix ".nix" (toString f)) && (isDefault f || isTop f)
      )
      all;
  in
    map (f: import f) chosen;
}
