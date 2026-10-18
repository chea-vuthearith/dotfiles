{
  # Hindsight long-term memory server for omp (memory.backend: hindsight in base/ai).
  # API :8888, web UI :9999; host networking keeps both behind the NixOS firewall,
  # so they are reachable only over tailscale0 (trusted in base/tailscale.nix).
  flake.modules.nixos.host-server = {config, ...}: let
    # sops `hindsight-env`: HINDSIGHT_API_LLM_API_KEY=sk-ant-oat01-... (from `claude setup-token`).
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
          # Claude Agent SDK billed to the Claude subscription via the setup-token in envFile.
          HINDSIGHT_API_LLM_PROVIDER = "claude-code";
          HINDSIGHT_API_LLM_MODEL = "claude-haiku-4-5";
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
