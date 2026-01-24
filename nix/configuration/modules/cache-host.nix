{ pkgs, username, ... }: {
  services.nix-serve = {
    enable = true;
    port = 5000;
    package = pkgs.nix-serve-ng;
  };
}
