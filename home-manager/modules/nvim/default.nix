{
  pkgs,
  config,
  inputs,
  ...
}: let
  nvimConfDir = "${config.home.homeDirectory}/dotfiles/home-manager/modules/nvim/conf";
in {
  home.packages = with pkgs; [
    # General/Editor
    neovim

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
  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"]; # for nixd lsp
  programs.zsh.shellAliases = {vi = "nvim";};
  home.file = {
    ".config/nvim" = {
      source =
        config.lib.file.mkOutOfStoreSymlink nvimConfDir; # lazy vim is self managed
    };

    "${nvimConfDir}/lua/plugins/colors.lua" = {
      text = with config.lib.stylix.colors; ''
        return {
          {
            "nvim-mini/mini.base16",
            opts = {
              palette = {
                base00 = "#000000",
                base01 = "${base01-hex}",
                base02 = "${base02-hex}",
                base03 = "${base03-hex}",
                base04 = "${base04-hex}",
                base05 = "${base05-hex}",
                base06 = "${base06-hex}",
                base07 = "${base07-hex}",
                base08 = "${base08-hex}",
                base09 = "${base09-hex}",
                base0A = "${base0A-hex}",
                base0B = "${base0B-hex}",
                base0C = "${base0C-hex}",
                base0D = "${base0D-hex}",
                base0E = "${base0E-hex}",
                base0F = "${base0F-hex}",
              },
            },
          },
        }

      '';
    };
  };

  programs.neovide = {
    enable = true;
    settings = {
      font = {
        normal = ["FiraCode Nerd Font" "Noto Sans Khmer"];
        italic = ["VictorMono Nerd Font"];
        size = 12;
      };
    };
  };
}
