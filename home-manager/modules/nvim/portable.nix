{pkgs}: let
  version = "1.0.0";
  nvimConfDir = ./conf;
  inherit (pkgs.stdenv) lib;
  extraRuntimeDeps = import ./extra-packages.nix {inherit pkgs;};
in
  pkgs.stdenv.mkDerivation {
    pname = "nvim-portable";
    inherit version;

    nativeBuildInputs = [pkgs.makeWrapper];
    buildInputs = [pkgs.neovim] ++ extraRuntimeDeps;
    src = nvimConfDir;

    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/share/nvim-config

      # Copy config
      cp -r ${nvimConfDir}/* $out/share/nvim-config/

      # Wrap Neovim to use this config and include all dependencies
      makeWrapper ${pkgs.neovim}/bin/nvim $out/bin/nvim \
        --prefix PATH : "${lib.makeBinPath extraRuntimeDeps}" \
        --set XDG_CONFIG_HOME $out/share/nvim-config \
        --set XDG_DATA_HOME $out/share/nvim-config
    '';

    passthru = {};

    meta = {
      description = "Fully configured Neovim shell with all LSPs, plugins, and formatters baked in";
      license = lib.licenses.mit;
      mainProgram = "nvim";
    };
  }
