{inputs, ...}: {
  flake.modules.nixos.desktop = {pkgs, ...}: {
    nixpkgs.overlays = [
      (final: prev: let
        inherit (final.stdenv.hostPlatform) system;
      in {
        inherit (inputs.hyprland.packages.${system}) hyprland;
        hyprlandPlugins =
          prev.hyprlandPlugins
          // {
            inherit (inputs.hyprsplit.packages.${system}) hyprsplitlua;
            inherit (inputs.hypr-dynamic-cursors.packages.${system}) hypr-dynamic-cursors;
          };
      })
    ];
    nix.settings = {
      extra-substituters = ["https://hyprland.cachix.org"];
      extra-trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };
    programs.hyprland = {
      enable = true;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };
  };
  flake.modules.homeManager.desktop = {
    config,
    pkgs,
    lib,
    ...
  }: {
    xdg.configFile = {
      "hypr/xdph.conf".text = ''
        screencopy {
          allow_token_by_default = true
        }
      '';
      "hypr/conf".source = config.lib.file.mkOutOfStoreSymlink (lib.toLocal ./conf);
      "hypr/hyprland.lua".text = ''
      '';
    };

    home.file = {
      "${lib.toLocal ./.luarc.json}".text = builtins.toJSON {
        workspace.library = [
          "${pkgs.hyprland}/share/hypr/stubs"
        ];
        diagnostics.globals = ["hl"];
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      extraLuaFiles = {
        "hyprsplit/init" = {
          autoLoad = false; # loaded by keybinds
          content = builtins.readFile "${pkgs.hyprlandPlugins.hyprsplitlua}/share/hyprsplit/init.lua";
        };
        "conf" = {
          content = ''
            require("conf.general")
            require("conf.keybinds")
            require("conf.rules")
            require("conf.auto")
          '';
        };
      };

      plugins = [
        pkgs.hyprlandPlugins.hypr-dynamic-cursors
      ];
    };
  };
}
