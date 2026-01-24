{ pkgs, ... }: {
  home.packages = with pkgs; [ nix-serve ];
  services.nix-serve.enable = true;
  # Do NOT set services.nix-serve.secretKeyFile

}
