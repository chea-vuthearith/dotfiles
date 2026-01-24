{ config, pkgs, ... }: {
  nixpkgs = { config = { allowUnfree = true; }; };
  home = { packages = with pkgs; [ cheese bluez bluez-tools ]; };
  home = {
    stateVersion = "24.11";
    preferXdgDirectories = true;
    sessionVariables = {
      PAGER = "less -X -F";
      EDITOR = "nvim";
      NIXOS_OZONE_WL = "1";
      TERMCMD = "wezterm start --always-new-process";
      NIXPKGS_ALLOW_UNFREE = 1;
    };
  };

}
