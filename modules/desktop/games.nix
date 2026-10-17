{...}: {
  flake.modules.homeManager.desktop = {pkgs, ...}: {
    home.packages = [pkgs.umu-launcher];
  };
}
