{...}: {
  flake.modules.homeManager.base = {...}: {
    programs = {
      direnv = {
        enable = true;
        enableZshIntegration = true;
        silent = true;
        # Roots dev envs and flake inputs in .direnv/ so nix-gc keeps them; caches the env.
        nix-direnv.enable = true;
      };
    };
  };
}
