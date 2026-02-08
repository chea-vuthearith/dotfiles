{
  pkgs,
  config,
  inputs,
  ...
}: let
  nvimConfDir = "${config.home.homeDirectory}/dotfiles/home-manager/modules/nvim/conf";
in {
  home = {
    sessionVariables = {
      PAGER = "nvimpager";
    };
    packages = with pkgs; [
      nvimpager

      # Hypr
      hyprls

      # Nix
      nixd
      alejandra
      statix

      # Python
      pyright
      ruff

      # JavaScript/TypeScript
      vtsls
      biome

      # Lua
      lua-language-server
      stylua

      #a Markdown
      markdown-toc
      markdownlint-cli2
      marksman

      # Shell/Bash
      bash-language-server
      shellcheck
      shfmt

      # Docker
      docker-compose-language-service
      dockerfile-language-server
      hadolint

      # SQL
      sqlfluff
      prisma-language-server

      # CSS/HTML/Frontend
      tailwindcss-language-server

      # Tree-sitter
      tree-sitter

      # YAML
      yaml-language-server
    ];

    file = {
      "${config.xdg.configHome}/nvim/lua".source =
        config.lib.file.mkOutOfStoreSymlink "${nvimConfDir}/lua"; # lazy vim is self managed

      "${config.xdg.configHome}/nvim/lazy-lock.json".source =
        config.lib.file.mkOutOfStoreSymlink "${nvimConfDir}/lazy-lock.json";

      "${config.xdg.configHome}/nvim/lazyvim.json".source =
        config.lib.file.mkOutOfStoreSymlink "${nvimConfDir}/lazyvim.json";

      "${config.xdg.configHome}/nvim/stylua.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${nvimConfDir}/stylua.toml";
    };
  };

  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"]; # for nixd lsp

  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      defaultEditor = true;
      initLua = ''
        require("config.lazy")
      '';
    };

    neovide = {
      enable = true;
      settings = {
        font = {
          normal = ["FiraCode Nerd Font" "Noto Sans Khmer"];
          italic = ["VictorMono Nerd Font"];
          size = 12;
        };
      };
    };
  };
}
