{...}: {
  flake.modules.homeManager.base = {pkgs, ...}: {
    home.packages = with pkgs; [
      gcc
      libgcc
      gnumake
      gnused
    ];
  };
}
