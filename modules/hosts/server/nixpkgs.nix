{inputs, ...}: {
  flake.modules.nixos.host-server = {pkgs, ...}: let
    inherit (pkgs.stdenv.hostPlatform) system;
  in {
    nixpkgs = {
      config.allowUnfree = true;
      overlays = [
        (_final: _prev: {
          inherit (inputs.llm-agents.packages.${system}) omp;
          inherit (inputs.herdr.packages.${system}) herdr;
        })
      ];
    };
  };
}
