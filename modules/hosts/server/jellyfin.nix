{config, ...}: let
  inherit (config) username;
in {
  # Media server on :8096 (LAN/tailnet), and at https://server.orfe-mizar.ts.net:8443/
  # via Tailscale Serve (tailnet only); Stremio add-ons need HTTPS. :443 is Frigate's
  # (frigate.nix). Library lives on the storage disk (storage.nix); files are owned by
  # the login user (group media) and world-readable, so jellyfin needs no extra groups.
  flake.modules.nixos.host-server = {
    config,
    lib,
    ...
  }: {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };
    systemd.tmpfiles.rules = [
      "d /srv/storage/media 0755 ${username} users -"
      # Group media + setgid so Sonarr (media-automation.nix) can import; world-readable.
      "d /srv/storage/media/shows 2775 ${username} media -"
    ];
    # Library is on a nofail mount; don't start against an empty mountpoint.
    systemd.services.jellyfin.unitConfig.RequiresMountsFor = ["/srv/storage"];

    # Same pattern as frigate.nix's tailscale-funnel, but `serve`: tailnet only, not public.
    systemd.services.tailscale-serve-jellyfin = {
      after = ["tailscaled.service" "tailscaled-autoconnect.service" "tailscaled-set.service"];
      wants = ["tailscaled.service"];
      wantedBy = ["multi-user.target"];
      partOf = ["tailscaled.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${lib.getExe config.services.tailscale.package} serve --bg --yes --https=8443 http://127.0.0.1:8096";
        Restart = "on-failure";
        RestartSec = "10s";
      };
    };
  };
}
