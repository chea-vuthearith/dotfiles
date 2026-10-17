{config, ...}: let
  inherit (config) username;
in {
  # Server signs everything harmonia serves, including builds it ran for workstations.
  # Key (sops `harmonia-key`) made with: nix-store --generate-binary-cache-key server-1 key key.pub
  flake.modules.nixos.host-server = {config, ...}: {
    sops.secrets.harmonia-key = {};
    services.harmonia.cache.signKeyPaths = [config.sops.secrets.harmonia-key.path];
  };

  # Workstations offload builds to server (Tailscale SSH) and substitute from its cache.
  flake.modules.nixos.desktop = {
    nix = {
      distributedBuilds = true;
      buildMachines = [
        {
          hostName = "server";
          sshUser = username;
          system = "x86_64-linux";
          protocol = "ssh-ng";
          maxJobs = 4;
          speedFactor = 2;
          supportedFeatures = ["nixos-test" "big-parallel" "kvm"];
        }
      ];
      settings = {
        # Server fetches from public caches itself instead of via the workstation.
        builders-use-substitutes = true;
        extra-substituters = ["http://server:5000"];
        extra-trusted-public-keys = ["server-1:fEDN/SamiRBT+SbeNiVEbpng9uAPkjSAgGPYjCtKb84="];
        # Server offline: give up quickly and build/fetch elsewhere.
        connect-timeout = 5;
        fallback = true;
      };
    };
    # nix-daemon's root ssh must accept server's host key non-interactively.
    programs.ssh.extraConfig = ''
      Host server
        StrictHostKeyChecking accept-new
    '';
  };
}
