{
  # Local LLM for Hindsight (hindsight.nix) on the GTX 1050 Ti (nvidia.nix).
  # Loopback only; Hindsight reaches it via host networking.
  flake.modules.nixos.host-server = {pkgs, ...}: {
    services.ollama = {
      enable = true;
      # = ollama-cuda, but against cudaPackages_12: CUDA 13 dropped sm_61 (nvidia.nix).
      # Overriding ollama-cuda itself would still evaluate its CUDA 13 build and fail.
      package = pkgs.ollama.override {
        acceleration = "cuda";
        cudaPackages = pkgs.cudaPackages_12;
      };
      host = "127.0.0.1";
      # ~2 GB at Q4: fits the 4 GB VRAM with room for an 8k context.
      loadModels = ["qwen2.5:3b"];
    };
    # Ollama probes GPUs once at startup; at boot it raced the nvidia module load and
    # settled on CPU. nvidia-persistenced is up only once the driver is initialised.
    systemd.services.ollama = {
      after = ["nvidia-persistenced.service"];
      wants = ["nvidia-persistenced.service"];
      # Model loads and CPU fallback must not starve Frigate's CPU detector (frigate.nix).
      serviceConfig = {
        Nice = 10;
        CPUWeight = 20;
      };
    };
  };
}
