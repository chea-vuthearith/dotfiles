return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        lua_ls = {},
        tsgo = {
          settings = {
            typescript = {
              preferences = {
                importModuleSpecifier = "non-relative",
                importModuleSpecifierPreference = "non-relative",
                autoImportSpecifierExcludeRegexes = {
                  "^@mui/[^/]+$",
                },
              },
            },
          },
        },
        nixd = {
          settings = {
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
          },
        },
        biome = {},
        ty = {},
        yamlls = {},
        taplo = {},
        prismals = {},
        copilot = {
          settings = {
            telemetry = { telemetryLevel = "none" },
          },
        },
        bashls = {},
        marksman = {},
        pyright = { enabled = false },
      },
    },
  },
}
