{ ... }: {
  nix.settings = {
    substituters = [ "http://192.168.108.74:5000" ];
    require-sigs = false;
  };
}
