{...}: {
  flake.modules.nixos.desktop = {pkgs, ...}: {
    environment.defaultPackages = with pkgs; [
      ntfs3g
    ];
  };
}
