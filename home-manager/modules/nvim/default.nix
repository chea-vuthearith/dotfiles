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
