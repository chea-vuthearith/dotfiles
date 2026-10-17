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
            # - binds.workspace_back_and_forth is an int now; Lua treats 0 as true.
            # - skip mirrored monitors on hotplug; focusing one crashes Hyprland
            #   (shezdy/hyprsplit#92, unmerged).
            hyprsplitlua = inputs.hyprsplit.packages.${system}.hyprsplitlua.overrideAttrs (old: {
              buildCommand =
                old.buildCommand
                + ''
                  chmod +w $out/share/hyprsplit/init.lua
                  substituteInPlace $out/share/hyprsplit/init.lua \
                    --replace-fail \
                      'hl.get_config("binds.workspace_back_and_forth")' \
                      'hl.get_config("binds.workspace_back_and_forth") ~= 0' \
                    --replace-fail \
                      'hl.on("monitor.added", function(monitor)' \
                      'hl.on("monitor.added", function(monitor) if monitor.is_mirror then return end'
                '';
            });
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
