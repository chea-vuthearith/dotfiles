{...}: {
  flake.modules.nixos.base = {pkgs, ...}: {
    environment.systemPackages = [pkgs.neovim]; # for root / sudoedit
  };
  flake.modules.homeManager.desktop = {...}: {
    stylix.targets.neovim.enable = false; # not good enough for nvim
  };
  flake.modules.homeManager.base = {
    pkgs,
    config,
    lib,
    ...
  }: {
    home = {
      sessionVariables = {
        BLINK_PATH = "${pkgs.vimPlugins.blink-cmp}";
      };
      packages = with pkgs; [
        tree-sitter
        ast-grep
      ];

      file = {
        "${config.xdg.configHome}/nvim/lua" = {
          source = config.lib.file.mkOutOfStoreSymlink (lib.toLocal ./conf/lua);
          recursive = true;
        };

        "${config.xdg.configHome}/nvim/.neoconf.json".source =
          config.lib.file.mkOutOfStoreSymlink (lib.toLocal ./conf/.neoconf.json);

        "${config.xdg.configHome}/nvim/lazy-lock.json".source =
          config.lib.file.mkOutOfStoreSymlink (lib.toLocal ./conf/lazy-lock.json);

        "${config.xdg.configHome}/nvim/lazyvim.json".source =
          config.lib.file.mkOutOfStoreSymlink (lib.toLocal ./conf/lazyvim.json);

        "${config.xdg.configHome}/nvim/stylua.toml".source =
          config.lib.file.mkOutOfStoreSymlink (lib.toLocal ./conf/stylua.toml);
      };
    };

    programs = {
      neovim = {
        withRuby = true;
        withPython3 = true;
        enable = true;
        viAlias = true;
        defaultEditor = true;
        initLua = ''require("config.lazy")'';
        extraLuaPackages = ps: [ps.jsregexp];
      };
    };
  };
}
