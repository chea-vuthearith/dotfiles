{ ... }: {
  nix.settings = {
    substituters = [ "http://192.168.108.74:5000" ];
    trusted-public-keys =
      [ "desktop:iLOMVEpAqoXMyrqlG+PLTs3h+KI63+bzPy/vpAmkzYc=" ];
  };
}
