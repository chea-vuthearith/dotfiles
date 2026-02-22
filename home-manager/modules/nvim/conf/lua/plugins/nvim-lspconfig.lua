return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              diagnostics = { globals = { "vim" } },
            },
          },
        },
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
