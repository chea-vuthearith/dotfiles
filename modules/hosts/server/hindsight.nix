{
  # Hindsight long-term memory server for omp (memory.backend: hindsight in base/ai).
  # API :8888, web UI :9999; host networking keeps both behind the NixOS firewall,
  # so they are reachable only over tailscale0 (trusted in base/tailscale.nix).
  flake.modules.nixos.host-server = {config, ...}: let
    # sops `hindsight-env`: HINDSIGHT_API_LLM_API_KEY=sk-ant-oat01-... (from `claude setup-token`),
    # unused with the ollama provider; kept for switching back to claude-code.
    envFile = config.sops.secrets.hindsight-env.path;
  in {
    sops.secrets.hindsight-env = {};
    virtualisation.oci-containers = {
      backend = "docker";
      containers.hindsight = {
        image = "ghcr.io/vectorize-io/hindsight:1.0.0";
        # Embedded Postgres (pg0) lives in this named volume.
        volumes = ["hindsight-data:/home/hindsight/.pg0"];
        environment = {
          # Local Ollama (ollama.nix); runs one request at a time on the 4 GB GPU.
          HINDSIGHT_API_LLM_PROVIDER = "ollama";
          HINDSIGHT_API_LLM_MODEL = "qwen2.5:3b";
          HINDSIGHT_API_LLM_BASE_URL = "http://127.0.0.1:11434";
          HINDSIGHT_API_LLM_OLLAMA_NUM_CTX = "8192";
          HINDSIGHT_API_LLM_MAX_CONCURRENT = "1";
          # One task at a time: 8 parallel tasks only queue on Ollama, so each task's
          # 3600 s wall clock (RETAIN_WALL_TIMEOUT) expired while waiting on the others.
          HINDSIGHT_API_WORKER_MAX_SLOTS = "1";
          HINDSIGHT_API_WORKER_CONSOLIDATION_RESERVED_SLOTS = "0";
          # Observation consolidation adds LLM calls per retain; too slow locally.
          HINDSIGHT_API_ENABLE_OBSERVATIONS = "false";
          # Stable identity so tasks claimed before a restart are resumed.
          HINDSIGHT_API_WORKER_ID = "hindsight";
        };
        environmentFiles = [envFile];
        extraOptions = ["--network=host" "--shm-size=1g"];
      };
    };

    # Skip (instead of crash-looping) until the host can decrypt the token.
    systemd.services.docker-hindsight.unitConfig.ConditionPathExists = envFile;
  };
}
