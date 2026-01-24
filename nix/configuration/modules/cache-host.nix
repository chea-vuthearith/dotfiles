{ pkgs, ... }: {
  services.nix-serve = {
    enable = true;
    port = 5000;
    package = pkgs.nix-serve-ng;
  };

  nix.settings = {
    connect-timeout = 5;
    download-attempts = 1;
  };
}
