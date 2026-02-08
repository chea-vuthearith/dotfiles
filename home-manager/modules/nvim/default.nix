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
      tmux
      lsof

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

      # Markdown
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
      "${config.xdg.configHome}/nvim/lua" = {
        source = config.lib.file.mkOutOfStoreSymlink "${nvimConfDir}/lua";
        recursive = true;
      }; # lazy vim is self managed

      "${config.xdg.configHome}/nvim/lazy-lock.json".source =
        config.lib.file.mkOutOfStoreSymlink "${nvimConfDir}/lazy-lock.json";

      "${config.xdg.configHome}/nvim/lazyvim.json".source =
        config.lib.file.mkOutOfStoreSymlink "${nvimConfDir}/lazyvim.json";

      "${config.xdg.configHome}/nvim/stylua.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${nvimConfDir}/stylua.toml";

      # pager config, should only include theme
      "${config.xdg.configHome}/nvimpager/init.lua".text = ''
        local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
        if not (vim.uv or vim.loop).fs_stat(lazypath) then
          local lazyrepo = "https://github.com/folke/lazy.nvim.git"
          local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
          if vim.v.shell_error ~= 0 then
            vim.api.nvim_echo({
              { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
              { out, "WarningMsg" },
              { "\nPress any key to exit..." },
            }, true, {})
            vim.fn.getchar()
            os.exit(1)
          end
        end
        vim.opt.rtp:prepend(lazypath)

        vim.g.mapleader = " "
        vim.g.maplocalleader = "\\"

        require("lazy").setup({
          spec = {
            { import = "color-scheme" },
          },
          checker = { enabled = false },
        })

        vim.cmd.colorscheme "catppuccin-mocha"
      '';
      "${config.xdg.configHome}/nvimpager/lua/color-scheme.lua".source =
        config.lib.file.mkOutOfStoreSymlink "${nvimConfDir}/lua/plugins/color-scheme.lua";
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
