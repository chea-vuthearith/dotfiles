{
  # Stremio add-on that lists/streams the Jellyfin library (jellyfin.nix), at
  # https://server.orfe-mizar.ts.net:10000/ via Tailscale Serve (tailnet only).
  # Install URLs are https://…:10000/<token>/manifest.json, where the token is
  # base64url({jellyfinUrl, jellyfinApiKey}): stateless, so they survive redeploys.
  # config.json in the state dir only holds configs saved via the /manage page.
  flake.modules.nixos.host-server = {
    config,
    lib,
    pkgs,
    ...
  }: let
    port = 7000;
    stremio-jellyfin = pkgs.buildNpmPackage {
      pname = "stremio-jellyfin";
      version = "1.0.0-unstable-2026-11-26";
      src = pkgs.fetchFromGitHub {
        owner = "shaikhnedab";
        repo = "stremio-jellyfin";
        rev = "13c86083993c30d7936c9f0f63d403fcbc4d5875";
        hash = "sha256-/DSNlgBYnxZKjXFjlnYDs1XCPksIaZltAxybj1fakMc=";
      };
      # Jellyfin 10.11+ auth (MediaBrowser header, not the dropped api_key param),
      # external SRT subtitles, bingeGroup hint, and a HOST env to bind loopback.
      patches = [./stremio-jellyfin.patch];
      npmDepsHash = "sha256-P0gp9NXVdg+pXOUQCPQcKNLu2dLdLU+uBS3PQ4nY3u0=";
      dontNpmBuild = true;
      installPhase = ''
        runHook preInstall
        mkdir -p $out/lib/stremio-jellyfin $out/bin
        cp -r index.js src public node_modules package.json $out/lib/stremio-jellyfin/
        makeWrapper ${lib.getExe pkgs.nodejs} $out/bin/stremio-jellyfin \
          --add-flags $out/lib/stremio-jellyfin/index.js
        runHook postInstall
      '';
      meta.mainProgram = "stremio-jellyfin";
    };
  in {
    # Guards the /manage page (adds/removes saved configs).
    sops.secrets.stremio-jellyfin-manage-key = {};

    systemd.services.stremio-jellyfin = {
      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      environment = {
        HOST = "127.0.0.1";
        PORT = toString port;
        CONFIG_PATH = "/var/lib/stremio-jellyfin/config.json";
      };
      # MANAGE_KEY is env-only; read it from the credential instead of the unit.
      script = ''
        MANAGE_KEY=$(< "$CREDENTIALS_DIRECTORY/manage-key")
        export MANAGE_KEY
        exec ${lib.getExe stremio-jellyfin}
      '';
      serviceConfig = {
        DynamicUser = true;
        StateDirectory = "stremio-jellyfin";
        LoadCredential = "manage-key:${config.sops.secrets.stremio-jellyfin-manage-key.path}";
        Restart = "on-failure";
        RestartSec = "5s";
        CapabilityBoundingSet = "";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        RestrictAddressFamilies = ["AF_INET" "AF_INET6"];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = ["@system-service" "~@privileged"];
        UMask = "0077";
      };
    };

    # Same as jellyfin.nix's tailscale-serve-jellyfin; Stremio needs HTTPS.
    systemd.services.tailscale-serve-stremio-jellyfin = {
      after = ["tailscaled.service" "tailscaled-autoconnect.service" "tailscaled-set.service"];
      wants = ["tailscaled.service"];
      wantedBy = ["multi-user.target"];
      partOf = ["tailscaled.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${lib.getExe config.services.tailscale.package} serve --bg --yes --https=10000 http://127.0.0.1:${toString port}";
        Restart = "on-failure";
        RestartSec = "10s";
      };
    };
  };
}
