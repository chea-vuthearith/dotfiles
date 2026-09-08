{...}: {
  home = {
    stateVersion = "24.11";
    preferXdgDirectories = true;
    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = 1;
    };
  };
}
