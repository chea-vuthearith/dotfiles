{
  # Local LLM server on the RX 6600-class card (Navi 23 / gfx1032, 8 GB VRAM).
  # Listens on all interfaces, but only tailscale0 is a trusted firewall interface
  # (base/tailscale.nix), so it is reachable over the tailnet as http://desktop:11434 and
  # not from the LAN. omp's `personal` profile uses it (base/ai/default.nix).
  flake.modules.nixos.host-desktop = {pkgs, ...}: {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
      # nixpkgs ROCm ships kernels for gfx1030 but not gfx1032; the RDNA2 ISA is the same.
      rocmOverrideGfx = "10.3.0";
      host = "0.0.0.0";
      # Pulled on every start (ollama-model-loader); kept even when dropped from this list.
      # Researched 2026-11 for 8 GB VRAM and agent tool calling:
      #   qwen3.5:9b  strongest tool calling that fits (BFCL-V4 66.1); small KV cache (hybrid attention)
      #   gemma4:e4b  top 8 GB pick on localagentbench.com (94.7)
      #   qwen3.5:4b  smaller fallback that leaves room for long context
      loadModels = ["qwen3.5:9b" "gemma4:e4b" "qwen3.5:4b"];
      environmentVariables = {
        # Ollama defaults to 4k below 24 GB VRAM; omp's system prompt and tools alone need more.
        OLLAMA_CONTEXT_LENGTH = "32768";
        # Halves the KV cache so the 9B and its context stay 100% on the GPU (needs flash attention).
        OLLAMA_FLASH_ATTENTION = "1";
        OLLAMA_KV_CACHE_TYPE = "q8_0";
        # 8 GB holds one model; never split two across GPU and CPU.
        OLLAMA_MAX_LOADED_MODELS = "1";
        OLLAMA_NUM_PARALLEL = "1";
      };
    };
  };
}
