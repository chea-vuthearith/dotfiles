{config, ...}: let
  inherit (config) username;
in {
  # Automated TV downloads: Prowlarr (indexers) -> Sonarr (picks releases) -> qBittorrent,
  # Sonarr then imports into the Jellyfin library (jellyfin.nix). Web UIs stay on the
  # tailnet (tailscale0 is trusted; no openFirewall, no funnel) without logins:
  # Sonarr :8989, Prowlarr :9696, qBittorrent :8080. Everything the UIs would store
  # (indexers, links, profiles, series) is pushed by media-provision over the REST APIs.
  flake.modules.nixos.host-server = {
    config,
    lib,
    pkgs,
    ...
  }: let
    storage = "/srv/storage";
    downloads = "${storage}/downloads";
    shows = "${storage}/media/shows";
    # Frigate records to ${storage}/frigate on this same disk and prunes its own recordings
    # when space runs low; Sonarr stops importing below this floor so media never eats it.
    minFreeMB = 250 * 1024;
    # Prowlarr definition names (github.com/Prowlarr/Indexers). Knaben aggregates many
    # sites (incl. 1337x/EZTV data). 1337x, EZTV, KAT, uindex and TorrentDownloads sit
    # behind Cloudflare (need FlareSolverr); Anidex/AniSource are unreachable;
    # TorrentGalaxy has no definition anymore.
    indexers = ["nyaasi" "limetorrents" "Knaben" "SubsPlease" "thepiratebay"];
    # Added with a search for missing episodes, so listing a show starts downloads.
    series = [];

    provision = pkgs.writeShellApplication {
      name = "media-provision";
      runtimeInputs = with pkgs; [curl jq gnused coreutils findutils];
      # jq filters live in single quotes on purpose.
      excludeShellChecks = ["SC2016"];
      text = ''
        # Reads the ApiKey each app generates into its config.xml on first start.
        apikey() {
          local key=""
          for _ in $(seq 120); do
            key=$(sed -n 's|.*<ApiKey>\(.*\)</ApiKey>.*|\1|p' "$1" 2>/dev/null || true)
            [ -n "$key" ] && break
            sleep 2
          done
          [ -n "$key" ] || { echo "no ApiKey in $1" >&2; exit 1; }
          echo "$key"
        }
        api() { local k=$1; shift; curl -fsS -H "X-Api-Key: $k" -H 'Content-Type: application/json' "$@"; }
        wait_up() {
          for _ in $(seq 120); do api "$1" "$2/system/status" >/dev/null 2>&1 && return; sleep 2; done
          echo "$2 not up" >&2; exit 1
        }
        # Generic GET-then-POST/PUT for provider lists (indexers, apps, clients, notifications).
        # $4 selects the schema entry, $5 is a jq filter applied to the new or existing item;
        # PUT only when the result differs.
        setf='def setf($m): .fields |= map(.name as $k | if ($m | has($k)) then .value = $m[$k] else . end);'
        ensure() {
          local k=$1 url=$2 name=$3 sel=$4 mut=$5 cur want
          cur=$(api "$k" "$url" | jq --arg n "$name" '.[] | select(.name == $n)')
          if [ -z "$cur" ]; then
            want=$(api "$k" "$url/schema" | jq --arg n "$name" "$setf [.[] | select($sel)][0] | .name = \$n | $mut")
            api "$k" -X POST "$url?forceSave=true" -d "$want" >/dev/null && echo "added $name"
          else
            want=$(jq "$setf $mut" <<<"$cur")
            # GETs mask secrets as ********; compare with those re-masked so only real
            # changes PUT (so a rotated secret alone isn't pushed).
            if [ "$(jq -S --argjson c "$cur" '.fields |= map(.name as $k | if any($c.fields[]; .name == $k and .value == "********") then .value = "********" else . end)' <<<"$want")" != "$(jq -S . <<<"$cur")" ]; then
              api "$k" -X PUT "$url/$(jq .id <<<"$cur")?forceSave=true" -d "$want" >/dev/null && echo "updated $name"
            fi
          fi
        }

        SONARR_KEY=$(apikey /var/lib/sonarr/.config/NzbDrone/config.xml)
        PROWLARR_KEY=$(apikey /var/lib/prowlarr/config.xml)
        JELLYFIN_KEY=$(cat ${config.sops.secrets.jellyfin-sonarr-api-key.path})
        export SONARR_KEY JELLYFIN_KEY
        sonarr=http://127.0.0.1:8989/api/v3
        prowlarr=http://127.0.0.1:9696/api/v1
        wait_up "$SONARR_KEY" "$sonarr"
        wait_up "$PROWLARR_KEY" "$prowlarr"

        # Sonarr
        if ! api "$SONARR_KEY" "$sonarr/rootfolder" | jq -e '.[] | select(.path == "${shows}")' >/dev/null; then
          api "$SONARR_KEY" -X POST "$sonarr/rootfolder" -d '{"path":"${shows}"}' >/dev/null
        fi
        # No upgrades or repack swaps: existing (trimmed) files are never replaced.
        mm=$(api "$SONARR_KEY" "$sonarr/config/mediamanagement" | jq -S .)
        want=$(jq -S '.minimumFreeSpaceWhenImporting = ${toString minFreeMB} | .downloadPropersAndRepacks = "doNotUpgrade" | .copyUsingHardlinks = true' <<<"$mm")
        [ "$want" = "$mm" ] || api "$SONARR_KEY" -X PUT "$sonarr/config/mediamanagement/$(jq .id <<<"$mm")" -d "$want" >/dev/null
        profile=$(api "$SONARR_KEY" "$sonarr/qualityprofile" | jq '.[] | select(.name == "HD-1080p")')
        if [ "$(jq .upgradeAllowed <<<"$profile")" != false ]; then
          api "$SONARR_KEY" -X PUT "$sonarr/qualityprofile/$(jq .id <<<"$profile")" -d "$(jq '.upgradeAllowed = false' <<<"$profile")" >/dev/null
        fi
        ensure "$SONARR_KEY" "$sonarr/downloadclient" qBittorrent '.implementation == "QBittorrent"' \
          '.enable = true | setf({host: "127.0.0.1", port: 8080, tvCategory: "tv-sonarr"})'
        ensure "$SONARR_KEY" "$sonarr/notification" Jellyfin '.implementation == "MediaBrowser"' \
          '.onDownload = true | .onUpgrade = true | .onRename = true | .onSeriesDelete = true | .onEpisodeFileDelete = true
           | setf({host: "127.0.0.1", port: 8096, apiKey: $ENV.JELLYFIN_KEY, updateLibrary: true, notify: false})'

        # Prowlarr: indexers, then push them to Sonarr (full sync).
        for def in ${lib.escapeShellArgs indexers}; do
          # Sites come and go (Cloudflare, dead mirrors); one failing indexer mustn't stop the rest.
          ensure "$PROWLARR_KEY" "$prowlarr/indexer" "$def" ".definitionName == \"$def\"" \
            '.enable = true | .appProfileId = 1 | if has("indexerUrls") then setf({baseUrl: .indexerUrls[0]}) else . end' || echo "indexer $def failed" >&2
        done
        ensure "$PROWLARR_KEY" "$prowlarr/applications" Sonarr '.implementation == "Sonarr"' \
          '.syncLevel = "fullSync" | setf({prowlarrUrl: "http://127.0.0.1:9696", baseUrl: "http://127.0.0.1:8989", apiKey: $ENV.SONARR_KEY})'

        # Series: add once (never touched again). Monitor "missing" leaves episodes that
        # already have files unmonitored; reuses an existing folder whose name matches.
        norm() { tr -cd '[:alnum:]' <<<"''${1,,}"; }
        pid=$(jq .id <<<"$profile")
        titles=(${lib.escapeShellArgs series})
        for title in "''${titles[@]}"; do
          found=$(api "$SONARR_KEY" -G "$sonarr/series/lookup" --data-urlencode "term=$title" \
            | jq --arg t "$title" '[.[] | select((.title | ascii_downcase) == ($t | ascii_downcase))][0]')
          [ "$found" != null ] || { echo "series not found: $title" >&2; continue; }
          [ "$(jq .id <<<"$found")" = null ] || continue
          path="${shows}/$(jq -r .folder <<<"$found")"
          for d in "${shows}"/*/; do
            [ "$(norm "$(basename "$d")")" = "$(norm "$title")" ] && path=''${d%/}
          done
          api "$SONARR_KEY" -X POST "$sonarr/series" -d "$(jq --arg p "$path" --argjson q "$pid" \
            '. + {path: $p, qualityProfileId: $q, seriesType: "anime", monitored: true, seasonFolder: true,
                  addOptions: {monitor: "missing", searchForMissingEpisodes: true}}' <<<"$found")" >/dev/null
          echo "added series $title"
        done
      '';
    };
  in {
    # Shared group: qBittorrent and Sonarr run with it as their *primary* group, because
    # both units use PrivateUsers=true, which maps only the primary group into the service.
    users.groups.media = {};
    users.users.${username}.extraGroups = ["media"];

    # Created in Jellyfin (Dashboard -> API Keys) for Sonarr's library refresh.
    sops.secrets.jellyfin-sonarr-api-key = {};

    # No login: tailnet-only, same as qBittorrent's whitelist below.
    services.prowlarr = {
      enable = true;
      settings.auth.method = "External";
    };
    services.sonarr = {
      enable = true;
      group = "media";
      settings.auth.method = "External";
    };

    # The module rewrites qBittorrent.conf from this on every start; WebUI changes don't stick.
    services.qbittorrent = {
      enable = true;
      group = "media";
      webuiPort = 8080;
      serverConfig = {
        LegalNotice.Accepted = true;
        BitTorrent.Session = {
          DefaultSavePath = downloads;
          # There is no total-size cap; preallocating makes a torrent that doesn't fit fail
          # up front instead of filling the disk mid-download. Sonarr's floor guards imports only.
          Preallocation = true;
          GlobalMaxRatio = 1;
          GlobalMaxSeedingMinutes = 1440;
          ShareLimitAction = "Stop";
        };
        Preferences.WebUI = {
          LocalHostAuth = false;
          AuthSubnetWhitelistEnabled = true;
          AuthSubnetWhitelist = "100.64.0.0/10";
        };
      };
    };

    # Same btrfs volume as the library so imports are hardlinks. setgid dirs + umask 002
    # keep everything group media and writable by both services and kuro; jellyfin reads
    # via the world r-x bits.
    systemd.tmpfiles.rules = ["d ${downloads} 2775 qbittorrent media -"];

    systemd.services =
      lib.genAttrs ["sonarr" "qbittorrent"] (_: {
        serviceConfig.UMask = lib.mkForce "0002";
        unitConfig.RequiresMountsFor = [storage];
      })
      // {
        # Existing library files predate the media group; fix group, g+w and setgid dirs
        # on every boot (only touches what differs).
        media-library-perms = {
          before = ["sonarr.service"];
          requiredBy = ["sonarr.service"];
          unitConfig.RequiresMountsFor = [storage];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          path = [pkgs.findutils];
          script = ''
            find ${shows} ! -group media -exec chgrp -h media {} +
            find ${shows} ! -type l ! -perm -g+w -exec chmod g+w {} +
            find ${shows} -type d ! -perm -g+s -exec chmod g+s {} +
          '';
        };
        # Idempotent; reruns on boot and whenever the script changes.
        media-provision = {
          after = ["sonarr.service" "prowlarr.service" "qbittorrent.service" "jellyfin.service"];
          wants = ["sonarr.service" "prowlarr.service" "qbittorrent.service"];
          wantedBy = ["multi-user.target"];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = lib.getExe provision;
          };
        };
      };
  };
}
