{pkgs, ...}: {
  services.nix-serve = {
    enable = true;
    port = 5000;
    package = pkgs.nix-serve-ng;
  };

  nix.settings = {require-sigs = false;};
}
