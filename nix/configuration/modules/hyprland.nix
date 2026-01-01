{ inputs, pkgs, ... }: {
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    package =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };
}
