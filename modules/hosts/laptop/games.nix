{...}: {
  flake.modules.homeManager.host-laptop = {pkgs, ...}: {
    home.packages = with pkgs; [
      umu-launcher
    ];
  };
}
