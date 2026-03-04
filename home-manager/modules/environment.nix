{...}: {
  nixpkgs = {config = {allowUnfree = true;};};
  services.ssh-agent = {
    enable = true;
    enableZshIntegration = true;
  };
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
      NIXPKGS_ALLOW_UNFREE = 1;
    };
  };
}
