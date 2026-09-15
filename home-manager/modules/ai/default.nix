{pkgs, ...}: {
  home.packages = with pkgs; [omp];
  home.file.".omp/agent/config.yml".text = ''
    modelRoles:
      vision: google-antigravity/gemini-3.7-flash
      default: anthropic/claude-sonnet-4-6
    symbolPreset: nerd
    composer:
      shape: pi
    theme:
      dark: titanium
      light: light
    setupVersion: 2
    colorBlindMode: false
    statusLine:
      preset: default
      separator: powerline
    memory:
      backend: mnemopi
    providers:
      memoryModel: online
    defaultThinkingLevel: auto
    checkpoint:
      enabled: true
    retry:
      maxRetryDelayMs: 21600000
      maxDelayMs: 21600000
      maxAgentDelayMs: 18000000
  '';
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
