{
  # Local LLM for Hindsight (hindsight.nix) on the GTX 1050 Ti (nvidia.nix).
  flake.modules.nixos.host-server = {pkgs, ...}: {
    services.ollama = {
      enable = true;
      # = ollama-cuda, but against cudaPackages_12: CUDA 13 dropped sm_61 (nvidia.nix).
      # Overriding ollama-cuda itself would still evaluate its CUDA 13 build and fail.
      package = pkgs.ollama.override {
        acceleration = "cuda";
        cudaPackages = pkgs.cudaPackages_12;
      };
      # Hindsight runs in a docker bridge container and reaches the host through
      # host.docker.internal (the docker0 gateway), so listen beyond loopback.
      # openFirewall stays false; the rule below admits only the bridge subnet.
      host = "0.0.0.0";
      # ~2 GB at Q4: fits the 4 GB VRAM with room for an 8k context.
      loadModels = ["qwen2.5:3b"];
    };
    # Reachable from docker bridge containers only (not the LAN/tailnet).
    networking.firewall.extraInputRules = ''
      ip saddr 172.16.0.0/12 tcp dport 11434 accept
    '';
    # Ollama probes GPUs once at startup; at boot it raced the nvidia module load and
    # settled on CPU. nvidia-persistenced is up only once the driver is initialised.
    systemd.services.ollama = {
      after = ["nvidia-persistenced.service"];
      wants = ["nvidia-persistenced.service"];
    };
  };
}
