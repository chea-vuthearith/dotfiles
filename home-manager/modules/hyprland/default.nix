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
      require("conf.general")
      require("conf.keybinds")
      require("conf.rules")
      require("conf.auto")
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

    plugins = [
      # pkgs.hyprlandPlugins.hyprsplit
      # pkgs.hyprlandPlugins.hyprtasking
      # pkgs.hyprlandPlugins.hypr-dynamic-cursors
    ];

    # extraConfig = ''
    #   source=${lib.toLocal ./hypr/general.conf}
    #   source=${lib.toLocal ./hypr/keybinds.conf}
    #   source=${lib.toLocal ./hypr/rules.conf}
    #   plugin:hyprtasking:bg_color=0xff${config.lib.stylix.colors.base00}
    # '';
  };
}
