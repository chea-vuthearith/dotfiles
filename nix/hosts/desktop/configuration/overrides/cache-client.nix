{ ... }: {
  nix.settings = {
    substituters = [ "http://192.168.100.108:5000" ];
    require-sigs = false;
  };
}
