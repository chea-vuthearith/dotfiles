{
  pkgs,
  lib,
}: let
  version = "1.0.0";
  nvimConfDir = ./conf;
  extraRuntimeDeps = import ./extra-packages.nix {inherit pkgs;};

  initLua = pkgs.writeText "init.lua" ''
    require("config.lazy")
  '';
in
  pkgs.stdenv.mkDerivation {
    pname = "nvim-portable";
    inherit version;
    nativeBuildInputs = [pkgs.makeWrapper];
    buildInputs = [pkgs.neovim] ++ extraRuntimeDeps;
    src = nvimConfDir;
    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/share/nvim-portable/lua

      # Copy config files
      cp -r ${nvimConfDir}/* $out/share/nvim-portable

      # Copy init.lua
      cp ${initLua} $out/share/nvim-portable/init.lua

      # Wrap Neovim to use this config and include all dependencies
      makeWrapper ${pkgs.neovim}/bin/nvim $out/bin/nvim \
        --prefix PATH : "${lib.makeBinPath extraRuntimeDeps}" \
        --set NVIM_APPNAME nvim-portable \
        --set XDG_CONFIG_HOME $out/share \
        --set-default XDG_DATA_HOME "\$HOME/.local/share" \
        --set-default XDG_STATE_HOME "\$HOME/.local/state" \
        --set-default XDG_CACHE_HOME "\$HOME/.cache"
    '';
    passthru = {};
    meta = {
      description = "Fully configured Neovim shell with all LSPs, plugins, and formatters baked in";
      license = lib.licenses.mit;
      mainProgram = "nvim";
    };
  }
