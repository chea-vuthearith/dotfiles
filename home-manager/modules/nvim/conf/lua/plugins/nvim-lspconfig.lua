return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        tsgo = {},
        vtsls = {
          enabled = false,
        },
        nixd = {
          nixpkgs = {
            expr = "import <nixpkgs> { }",
            formatting = { command = { "alejandra" } },
            options = {
              nixos = {
                expr = '(builtins.getFlake "github:chea-vuthearith/dotfiles").nixosConfigurations.desktop.options',
              },
              home_manager = {
                expr = '(builtins.getFlake "github:chea-vuthearith/dotfiles").nixosConfigurations.desktop.options.home-manager.users.type.getSubOptions []',
              },
            },
          },
        },
        -- vtsls = { settings = { typescript = { preferences = { importModuleSpecifier = "non-relative" } } } },
        biome = {},
        hyprls = {},
      },
    },
  },
}
