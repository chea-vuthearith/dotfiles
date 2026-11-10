{
  inputs,
  config,
  ...
}: let
  inherit (config) username;
in {
  # nixpkgs 1d06008 (2026-11-03): opencode 2.2.5 node_modules FOD hash is stale upstream.
  # Drop once nixpkgs ships the fixed hash (build fails with a hash mismatch → remove this).
  flake.modules.nixos.base = {
    nixpkgs.overlays = [
      (_final: prev: {
        opencode = prev.opencode.overrideAttrs (o: {
          node_modules = o.node_modules.overrideAttrs {
            outputHash = "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=";
          };
        });
      })
    ];
  };
  flake.modules.homeManager.base = {
    pkgs,
    lib,
    config,
    ...
  }: let
    # Agent skills for omp, Claude Code and opencode.
    # herdr: upstream skill from the pinned herdr input; herdr-team: multi-agent protocol on top;
    # orchestrator: plan and run branch owners; gh-stack: stacked PRs via the gh stack extension.
    skills = {
      herdr = "${inputs.herdr}/skills/herdr";
      herdr-team = ./skills/herdr-team;
      orchestrator = ./skills/orchestrator;
      gh-stack = ./skills/gh-stack;
    };
    # herdr-label / herdr-name / herdr-msg, used by the herdr-team skill and agent-rules.md.
    herdrHelpers = pkgs.runCommand "herdr-agent-helpers" {nativeBuildInputs = [pkgs.makeWrapper];} ''
      mkdir -p $out/bin
      for s in ${./skills/herdr-team/scripts}/*; do
        makeWrapper ${pkgs.bash}/bin/bash $out/bin/$(basename $s) \
          --add-flags $s --prefix PATH : ${lib.makeBinPath [pkgs.jq pkgs.coreutils pkgs.gnused pkgs.socat]}
      done
    '';
    # Always-on instructions shared by every agent (omp appends them to APPEND_SYSTEM.md).
    agentRules = builtins.readFile ./agent-rules.md;
    # Opens a fresh Claude usage window on every Anthropic OAuth account with one
    # 10-token message each; see ./warm-claude.sh.
    warmClaude = pkgs.writeShellApplication {
      name = "warm-claude";
      runtimeInputs = [config.programs.omp.package pkgs.curl pkgs.coreutils];
      text = builtins.readFile ./warm-claude.sh;
    };
  in {
    imports = [inputs.omp.homeManagerModules.default];

    # trafilatura: HTML-to-text CLI that omp can use (previously a `uv tool` install).
    home.packages = [pkgs.python3Packages.trafilatura herdrHelpers warmClaude];

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
          # task subagent: plans and writes code on opus-low (no prewalk to haiku)
          task = "anthropic/claude-opus-5-5:low";
          # frequent, trivial outputs
          commit = "anthropic/claude-haiku-5-5:high";
          tiny = "anthropic/claude-haiku-5-5:high";
        };
        # sessions and task subagents stay on opus-low; haiku only for commit/tiny/smol utility work
        prewalk.enabled = false;
        task.prewalk = false;
        compaction = {
          enabled = true;
          # fixed triggers per model: opus compact at 327k, haiku at 475k
          modelThresholds = {
            "anthropic/claude-opus-5-5" = "f327000";
            "anthropic/claude-haiku-5-5" = "f475000";
          };
          # keep each handoff summary on disk, so decisions lost in compaction can be looked up
          handoffSaveToDisk = true;
          # compact an idle agent above 200k before its prompt cache goes cold
          idleEnabled = true;
          # notes-backed context windows: rollover keeps a notebook + searchable full history instead of lossy summaries
          experimentalContextManagement = true;
        };
        # many herdr agents share one repo: refuse stash / reset --hard / checkout that discard others' work
        bash.gitGuard = true;
        # obfuscate secret-looking env values, credential shapes and ~/.omp/agent/secrets.yml entries before sending
        secrets.enabled = true;
        lsp.diagnosticsOnEdit = true;
        tui.vimMode = true;
        startup = {
          quiet = true;
          checkUpdate = false;
        };
        # skills stay declarative (modules/base/ai/skills/); autolearn would write unmanaged ones to ~/.omp/agent/managed-skills
        autolearn.enabled = false;
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
        # deliver every queued steer/follow-up message in one turn instead of one turn each
        steeringMode = "all";
        followUpMode = "all";
        # inline tail of spilled tool output (default 500 lines, ~2.5K tokens); the rest stays readable as artifact://
        tools.artifactTailLines = 200;
      };
    };

    home.file =
      lib.mapAttrs' (name: src: lib.nameValuePair ".omp/agent/skills/${name}" {source = src;}) skills
      // {
        # omp custom tools; see ./omp/tools/README.md
        ".omp/agent/tools/herdr-worktree.ts".source = ./omp/tools/herdr-worktree.ts;
        ".omp/agent/APPEND_SYSTEM.md".text = builtins.readFile ./omp/APPEND_SYSTEM.md + "\n" + agentRules;
        # herdr-msg delivers to omp through this socket instead of typing into the prompt
        ".omp/agent/extensions/herdr-inbox.ts".source = ./omp/extensions/herdr-inbox.ts;
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

    # A Claude subscription's 5-hour window starts with the first message an
    # account receives and lives for 5 hours, so a tiny message at 07:00 buys a
    # window that covers the working day. Every Anthropic account gets one
    # message of its own (~10 tokens each) before the day starts.
    systemd.user.services.warm-claude = {
      Unit.Description = "Open a fresh Claude usage window on every Anthropic account";
      Service = {
        Type = "oneshot";
        ExecStart = "${warmClaude}/bin/warm-claude";
        Environment = "HOME=/home/${username}";
      };
    };

    systemd.user.timers.warm-claude = {
      Unit.Description = "Warm the Claude accounts every weekday at 07:00";
      Timer = {
        OnCalendar = "Mon..Fri *-*-* 07:00:00";
        # A laptop asleep at 07:00 runs it as soon as it wakes up.
        Persistent = true;
      };
      Install.WantedBy = ["timers.target"];
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
