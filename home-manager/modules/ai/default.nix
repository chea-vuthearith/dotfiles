{pkgs, ...}: {
  programs = {
    opencode = {
      enable = true;
      settings = {
        plugin = ["@mohak34/opencode-notifier@latest"];
      };
    };

    claude-code = {
      enable = true;
      settings = {
        hooks = {
          StopFailure = [
            {
              matcher = "rate_limit";
              hooks = [
                {
                  type = "command";
                  command = "${pkgs.bash}/bin/bash ${./schedule-claude-retry.sh}";
                }
              ];
            }
          ];
        };
      };
      lspServers = {
        ty = {
          command = "${pkgs.ty}/bin/ty";
          args = ["server"];
          extensionToLanguage = {
            ".py" = "python";
            ".pyi" = "python";
          };
        };
        tsgo = {
          command = "${pkgs.typescript-go}/bin/tsgo";
          args = ["--lsp"];
          extensionToLanguage = {
            ".ts" = "typescript";
            ".tsx" = "typescriptreact";
            ".mts" = "typescript";
            ".cts" = "typescript";
            ".js" = "javascript";
            ".jsx" = "javascriptreact";
            ".mjs" = "javascript";
            ".cjs" = "javascript";
          };
        };
      };
    };
  };
}
