{
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
      # pkgs.hyprlandPlugins.split-monitor-workspaces
      # pkgs.hyprlandPlugins.hyprsplitlua
      # pkgs.hyprlandPlugins.hyprtasking
      pkgs.hyprlandPlugins.hypr-dynamic-cursors
    ];
  };
}
