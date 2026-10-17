{...}: {
  flake.modules.homeManager.base = {pkgs, ...}: {
    home.packages = with pkgs; [
      rustc
      cargo
    ];
  };
}
