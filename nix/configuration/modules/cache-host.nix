{ pkgs, username, ... }:
let nixServeConfig = "/home/${username}/.config/nix-serve";
in {
  system.activationScripts.nixServeKey.text = ''
    if [ ! -f "${nixServeConfig}/secret" ]; then
      mkdir ${nixServeConfig} -p
        ${pkgs.nix}/bin/nix-store --generate-binary-cache-key local-nix-cache ${nixServeConfig}/secret ${nixServeConfig}/public
      chown -R ${username} ${nixServeConfig}
      chmod 777 -R ${nixServeConfig}
    fi
  '';

  services.nix-serve = {
    enable = true;
    port = 5000;
    package = pkgs.nix-serve-ng;
    secretKeyFile = "${nixServeConfig}/secret";
  };
}
