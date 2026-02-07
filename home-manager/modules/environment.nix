{
  config,
  pkgs,
  ...
}: {
  nixpkgs = {config = {allowUnfree = true;};};
  home = {
    stateVersion = "24.11";
    preferXdgDirectories = true;
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      TERMCMD = "wezterm start --always-new-process";
      NIXPKGS_ALLOW_UNFREE = 1;
    };
  };
}
