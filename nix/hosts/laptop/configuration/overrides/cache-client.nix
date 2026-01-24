{ ... }: {
  nix.settings = {
    substituters = [ "http://192.168.100.74:5000" ];
    require-sigs = false;
  };
}
