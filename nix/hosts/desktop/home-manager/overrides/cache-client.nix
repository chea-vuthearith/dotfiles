{ ... }: {
  nix.settings = {
    substituters = [ "http://192.168.108.74:5000" ];
    trusted-public-keys =
      [ "local-nix-cache:AhF0FXOwu8HBWPpDd0S8QEptvnxMqhUTRlPIWBTLvio=" ];
  };
}
