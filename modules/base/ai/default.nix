{inputs, ...}: {
  flake.modules.homeManager.base = {
    pkgs,
    lib,
    ...
  }: let
    # Agent skills for omp, Claude Code and opencode.
    # herdr: upstream skill from the pinned herdr input; herdr-team: multi-agent protocol on top.
    skills = {
      herdr = "${inputs.herdr}/skills/herdr";
      herdr-team = ./skills/herdr-team;
    };
    # herdr-label / herdr-name / herdr-msg, used by the herdr-team skill and agent-rules.md.
    herdrHelpers = pkgs.runCommand "herdr-agent-helpers" {nativeBuildInputs = [pkgs.makeWrapper];} ''
      mkdir -p $out/bin
      for s in ${./skills/herdr-team/scripts}/*; do
        makeWrapper ${pkgs.bash}/bin/bash $out/bin/$(basename $s) \
          --add-flags $s --prefix PATH : ${lib.makeBinPath [pkgs.jq pkgs.coreutils pkgs.gnused]}
      done
    '';
    # Always-on instructions shared by every agent (omp appends them to APPEND_SYSTEM.md).
    agentRules = builtins.readFile ./agent-rules.md;
  in {
    imports = [inputs.omp.homeManagerModules.default];

    # trafilatura: HTML-to-text CLI that omp can use (previously a `uv tool` install).
    home.packages = [pkgs.python3Packages.trafilatura herdrHelpers];

    # programs.omp writes config.yml as a writable copy on every switch, so omp's
    # /settings can save until the next switch resets it.
    programs.omp = {
      enable = true;
      package = pkgs.omp; # nixpkgs build, not the flake's from-source one
      settings = {
        modelRoles = {
          vision = "google-antigravity/gemini-3.7-flash";
          # interactive: judgment and language, minimal wait/scratchpad
          default = "anthropic/claude-opus-5-5:low";
          # fast/cheap utility + prewalk handoff target
          smol = "anthropic/claude-haiku-5-5:high";
          # escape hatch when low-opus isn't enough
          slow = "anthropic/claude-opus-5-5:high";
          plan = "anthropic/claude-opus-5-5:high";
          # task subagent: plans on opus-low, prewalks to @smol (haiku) at first edit
          task = "anthropic/claude-opus-5-5:low";
          # frequent, trivial outputs
          commit = "anthropic/claude-haiku-5-5:high";
          tiny = "anthropic/claude-haiku-5-5:high";
        };
        # session starts on opus-low and stays there; only task subagents prewalk
        prewalk.enabled = false;
        task.prewalk = true;
        compaction = {
          enabled = true;
          # fixed triggers per model: opus compact at 327k, haiku at 475k
          modelThresholds = {
            "anthropic/claude-opus-5-5" = "f327000";
            "anthropic/claude-haiku-5-5" = "f475000";
          };
        };
        tui.vimMode = true;
        startup = {
          quiet = true;
          checkUpdate = false;
        };
        autolearn.enabled = true;
        symbolPreset = "nerd";
        composer.shape = "pi";
        theme = {
          dark = "titanium";
          light = "light";
        };
        setupVersion = 2;
        colorBlindMode = false;
        statusLine = {
          preset = "default";
          separator = "powerline";
        };
        memory.backend = "hindsight";
        hindsight.apiUrl = "http://server:8888";
        defaultThinkingLevel = "auto";
        checkpoint.enabled = true;
        retry.waitForUsageReset = true;
      };
    };

    home.file =
      lib.mapAttrs' (name: src: lib.nameValuePair ".omp/agent/skills/${name}" {source = src;}) skills
      // {
        # omp custom tools; see ./omp/tools/README.md
        ".omp/agent/tools/herdr-worktree.ts".source = ./omp/tools/herdr-worktree.ts;
        ".omp/agent/APPEND_SYSTEM.md".text = builtins.readFile ./omp/APPEND_SYSTEM.md + "\n" + agentRules;
        # herdr's omp integration (state reporting + session resume), generated from the
        # pinned herdr instead of a manual `herdr integration install omp`.
        # force: replaces the copy herdr installed by hand.
        ".omp/agent/extensions/herdr-omp-agent-state.ts" = {
          force = true;
          source = "${
            pkgs.runCommand "herdr-omp-integration" {} ''
              export HOME=$out XDG_CONFIG_HOME=$out/.config
              mkdir -p $out/.omp/agent/extensions
              ${pkgs.herdr}/bin/herdr integration install omp
            ''
          }/.omp/agent/extensions/herdr-omp-agent-state.ts";
        };
      };

    programs = {
      opencode = {
        enable = true;
        inherit skills;
        context = agentRules;
        settings = {
          plugin = ["@mohak34/opencode-notifier@latest"];
        };
      };

      claude-code = {
        enable = true;
        inherit skills;
        context = agentRules;
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
