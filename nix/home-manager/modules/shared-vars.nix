{ lib, ... }: {
  options.wallpaperPath = lib.mkOption {
    type = lib.types.path;
    description = "Shared wallpaper path used by multiple modules";
  };
}
