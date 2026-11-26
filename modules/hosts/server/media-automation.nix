{config, ...}: let
  inherit (config) username;
in {
  # Automated TV downloads: Prowlarr (indexers) -> Sonarr (picks releases) -> qBittorrent,
  # Sonarr then imports into the Jellyfin library (jellyfin.nix). Web UIs stay on the
  # tailnet (tailscale0 is trusted; no openFirewall, no funnel): Sonarr :8989,
  # Prowlarr :9696, qBittorrent :8080. Indexers, API keys and profiles are UI state;
  # first-run steps live in the runbook (PR description).
  flake.modules.nixos.host-server = {lib, ...}: let
    downloads = "/srv/storage/downloads";
  in {
    # Shared group: qBittorrent and Sonarr run with it as their *primary* group, because
    # both units use PrivateUsers=true, which maps only the primary group into the service.
    users.groups.media = {};
    users.users.${username}.extraGroups = ["media"];

    services.prowlarr.enable = true;

    services.sonarr = {
      enable = true;
      group = "media";
    };

    # The NixOS module rewrites qBittorrent.conf on every start when serverConfig is set,
    # which would wipe the WebUI password and settings; leave it empty and configure in the UI.
    services.qbittorrent = {
      enable = true;
      group = "media";
      webuiPort = 8080;
      extraArgs = ["--confirm-legal-notice"];
    };

    # Downloads sit on the same btrfs volume as the library so Sonarr can hardlink
    # (seeding continues without a second copy). setgid dirs + umask 002 keep everything
    # group media, writable by both services and kuro, readable by jellyfin (world r-x).
    systemd.tmpfiles.rules = [
      "d ${downloads} 2775 qbittorrent media -"
    ];
    systemd.services = lib.genAttrs ["sonarr" "qbittorrent"] (_: {
      serviceConfig.UMask = lib.mkForce "0002";
      unitConfig.RequiresMountsFor = ["/srv/storage"];
    });
  };
}
