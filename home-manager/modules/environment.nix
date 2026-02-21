{...}: {
  nixpkgs = {config = {allowUnfree = true;};};
  programs.keychain = {
    enable = true;
    enableZshIntegration = true;
    keys = [
      "id_ed25519"
    ];
  };
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
