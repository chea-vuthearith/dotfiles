{ pkgs, ... }: {
  home = { packages = with pkgs; [ cheese bluez bluez-tools]; };
}
