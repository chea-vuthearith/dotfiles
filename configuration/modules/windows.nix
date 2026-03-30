{pkgs, ...}: {
  environment.defaultPackages = with pkgs; [
    ntfs3g
  ];
}
