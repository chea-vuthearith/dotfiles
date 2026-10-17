{inputs, ...}: {
  flake.modules.nixos.base = {...}: {
    nixpkgs.overlays = [
      (final: _prev: {
        inherit (inputs.llm-agents.packages.${final.stdenv.hostPlatform.system}) omp;
      })
    ];
  };
  flake.modules.homeManager.base = {pkgs, ...}: {
    # omp custom tools; see ./omp/tools/README.md
    # trafilatura: HTML-to-text CLI that omp can use (previously a `uv tool` install).
    home.packages = with pkgs; [omp python3Packages.trafilatura];
    home.file.".omp/agent/tools/herdr-worktree.ts".source = ./omp/tools/herdr-worktree.ts;
    home.file.".omp/agent/APPEND_SYSTEM.md".source = ./omp/APPEND_SYSTEM.md;
    # herdr's omp integration (state reporting + session resume), generated from the
    # pinned herdr instead of a manual `herdr integration install omp`.
    # force: replaces the copy herdr installed by hand.
    home.file.".omp/agent/extensions/herdr-omp-agent-state.ts".force = true;
    home.file.".omp/agent/extensions/herdr-omp-agent-state.ts".source = "${
      pkgs.runCommand "herdr-omp-integration" {} ''
        export HOME=$out XDG_CONFIG_HOME=$out/.config
        mkdir -p $out/.omp/agent/extensions
        ${pkgs.herdr}/bin/herdr integration install omp
      ''
    }/.omp/agent/extensions/herdr-omp-agent-state.ts";
    home.file.".omp/agent/config.yml".text = ''
      modelRoles:
        vision: google-antigravity/gemini-3.7-flash
        default: anthropic/claude-opus-5-5
        smol: anthropic/claude-sonnet-5-5
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
            command = "${pkgs.typescript}/bin/tsgo";
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
  };
}
