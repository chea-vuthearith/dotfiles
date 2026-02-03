{ pkgs, ... }: {
  programs.nix-index = {
    enable = true;
    database.comma.enable = true;
  };
  # home.packages = with pkgs; [ comma ];
}
