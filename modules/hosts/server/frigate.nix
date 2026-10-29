{
  # Frigate NVR for the Hikvision DS-IPC-B12HV2-IA (PoE, 1080p H.264 + G.711 audio).
  # go2rtc holds the only camera connection and restreams it on 127.0.0.1:8554; Frigate
  # records the main stream, detects on the sub stream. UI: http://server/ over the tailnet
  # or the server's LAN IP (nginx :80), plus https://server.orfe-mizar.ts.net/ (:443, Tailscale
  # cert). Frigate login required. First login: admin, with
  # the password Frigate prints once to `journalctl -u frigate`.
  flake.modules.nixos.host-server = {
    config,
    lib,
    pkgs,
    ...
  }: let
    # DHCP lease; reserve it for 08:a1:89:ec:ea:50 on the router.
    camera = "192.168.0.160";
    # sops `cctv-pw`: the camera's `admin` password (set at activation).
    rtsp = channel: "rtsp://admin:\${CCTV_PASSWORD}@${camera}:554/Streaming/Channels/${channel}";
    recordings = "/srv/storage/frigate";
    # nixpkgs points `.model` at `ssdlite_mobilnet_v2.xml` (sic); the file is spelled correctly.
    ssdlite = pkgs.frigate.models.openvino.ssdlite_mobilenet_v2_coco;
    tsName = "server.orfe-mizar.ts.net";
    tsCertDir = "/var/lib/tailscale-cert";
  in {
    sops.secrets.cctv-pw = {};
    sops.templates.go2rtc-env = {
      content = "CCTV_PASSWORD=${config.sops.placeholder.cctv-pw}\n";
      restartUnits = ["go2rtc.service"];
    };

    services.go2rtc = {
      enable = true;
      settings = {
        api.listen = "127.0.0.1:1984";
        rtsp.listen = "127.0.0.1:8554";
        # go2rtc expands ${CCTV_PASSWORD} from the environment.
        streams = {
          # The extra ffmpeg source adds an AAC track: G.711 fits neither MP4 nor MSE.
          cctv = [(rtsp "101") "ffmpeg:cctv#audio=aac"];
          cctv_sub = rtsp "102";
        };
      };
    };
    systemd.services.go2rtc = {
      serviceConfig.EnvironmentFile = config.sops.templates.go2rtc-env.path;
      # Skip (instead of crash-looping) until the host can decrypt the password.
      unitConfig.ConditionPathExists = config.sops.templates.go2rtc-env.path;
    };

    services.frigate = {
      enable = true;
      hostname = "server";
      settings = {
        # Software decode only: the camera sends H.264 Baseline, which VA-API on the UHD 630
        # decodes only via allow_profile_mismatch, and that fails within seconds ("Failed to
        # sync surface"). Decoding the 640x360 detect stream costs a few % of one core.
        # OpenVINO on that iGPU crashes too (intel-compute-runtime-legacy1), so detection
        # runs on the CPU (~8 ms per inference).
        # Frigate 0.18 defaults this to false.
        detect.enabled = true;
        # go2rtc runs as its own service; Frigate only checks these names to offer the
        # live stream picker ("Restreaming is not enabled" while this is empty).
        go2rtc.streams = config.services.go2rtc.settings.streams;
        detectors.ov = {
          type = "openvino";
          device = "CPU";
        };
        model = {
          width = 300;
          height = 300;
          input_tensor = "nhwc";
          input_pixel_format = "bgr";
          path = "${dirOf ssdlite.model}/ssdlite_mobilenet_v2.xml";
          # A string, not the derivation: the module's null filter would recurse into it.
          labelmap_path = "${ssdlite.labelmap}";
        };
        objects.track = ["person" "car" "motorcycle"];
        # Every tracked object is an alert (Frigate's default is person + car).
        review.alerts.labels = ["person" "car" "motorcycle"];
        # Main stream is H.265 CBR 2048 kbit/s (set on the camera), ~23 GB/day with audio:
        # 7 days continuous is ~160 GB of the 1 TB disk; motion/events fill the rest. Frigate
        # also prunes the oldest recordings when the disk runs low.
        record = {
          enabled = true;
          continuous.days = 7;
          motion.days = 30;
          alerts.retain.days = 90;
          detections.retain.days = 90;
        };
        snapshots = {
          enabled = true;
          retain.default = 90;
        };
        cameras.cctv = {
          ffmpeg = {
            inputs = [
              {
                path = "rtsp://127.0.0.1:8554/cctv?video&audio=aac";
                input_args = "preset-rtsp-restream";
                roles = ["record"];
              }
              {
                path = "rtsp://127.0.0.1:8554/cctv_sub";
                input_args = "preset-rtsp-restream";
                roles = ["detect"];
              }
            ];
            output_args.record = "preset-record-generic-audio-copy";
          };
          detect = {
            width = 640;
            height = 360;
            fps = 5;
          };
          live.streams = {
            Main = "cctv";
            Sub = "cctv_sub";
          };
        };
      };
    };

    networking.firewall.allowedTCPPorts = [80 443];

    # HTTPS next to plain HTTP (addSSL keeps :80 serving). `tailscale cert` fetches a Let's
    # Encrypt cert for the MagicDNS name (needs HTTPS enabled in the tailnet admin console);
    # the daily timer renews it (tailscale only re-issues near expiry) and reloads nginx.
    services.nginx.virtualHosts.${config.services.frigate.hostname} = {
      addSSL = true;
      serverAliases = [tsName];
      sslCertificate = "${tsCertDir}/cert.pem";
      sslCertificateKey = "${tsCertDir}/key.pem";
      # The PWA's system bars follow theme-color: white for a light-mode phone (and always in
      # the manifest), under Frigate's dark UI. Rewrite both to black. gzip_static off, or
      # nginx serves the precompressed file and sub_filter never sees the text.
      locations = let
        black = ''
          gzip_static off;
          sub_filter_once off;
          sub_filter '#ffffff' '#000000';
        '';
      in {
        "/".extraConfig = black;
        "~ ^/assets/site-[^/]*\\.webmanifest$" = {
          root = "${config.services.frigate.package.web}";
          extraConfig = black + "sub_filter_types application/manifest+json;";
        };
      };
    };
    systemd.services.tailscale-cert = {
      after = ["tailscaled.service" "network-online.target"];
      wants = ["tailscaled.service" "network-online.target"];
      wantedBy = ["multi-user.target"];
      before = ["nginx.service"];
      path = [config.services.tailscale.package pkgs.openssl];
      serviceConfig = {
        Type = "oneshot";
        StateDirectory = "tailscale-cert";
        StateDirectoryMode = "0750";
        Group = "nginx";
        UMask = "0027";
      };
      # A missing cert would fail nginx and take :80 down too, so a failed first fetch
      # leaves a short-lived self-signed placeholder until the next run.
      script = ''
        if ! tailscale cert --cert-file ${tsCertDir}/cert.pem --key-file ${tsCertDir}/key.pem ${tsName} \
          && [ ! -s ${tsCertDir}/cert.pem ]; then
          openssl req -x509 -newkey rsa:2048 -nodes -days 1 -subj /CN=${tsName} \
            -keyout ${tsCertDir}/key.pem -out ${tsCertDir}/cert.pem
        fi
        # tailscale writes the key 0600 root; nginx (the unit's group) must read it.
        chgrp nginx ${tsCertDir}/cert.pem ${tsCertDir}/key.pem
        chmod 0640 ${tsCertDir}/cert.pem ${tsCertDir}/key.pem
        # --no-block: nginx is ordered after this unit, so a waiting reload would deadlock.
        if systemctl is-active -q nginx.service; then systemctl reload --no-block nginx.service; fi
      '';
    };
    systemd.timers.tailscale-cert = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "daily";
        RandomizedDelaySec = "1h";
        Persistent = true;
      };
    };
    systemd.services.nginx = {
      wants = ["tailscale-cert.service"];
      after = ["tailscale-cert.service"];
    };

    # Recordings live on the HDD. A system-wide bind mount, not BindPaths: nginx serves
    # review playback (/vod) from /var/lib/frigate/recordings too, and a Frigate-only
    # mount left it 404ing every clip. nofail keeps boot up without the HDD; Frigate
    # then refuses to start instead of recording onto the SSD.
    systemd.tmpfiles.rules = ["d ${recordings} 0750 frigate frigate -"];
    fileSystems."/var/lib/frigate/recordings" = {
      device = recordings;
      fsType = "none";
      options = ["bind" "nofail" "x-systemd.requires-mounts-for=/srv/storage"];
    };
    systemd.services.frigate = {
      unitConfig.RequiresMountsFor = ["/var/lib/frigate/recordings"];
      # libgomp's default active wait spun ~12 idle threads in frigate.process:cctv at
      # 300-400% CPU ("high detect CPU usage"); passive drops it to ~7%.
      environment.OMP_WAIT_POLICY = "PASSIVE";
      serviceConfig = {
        # OpenVINO's CPU plugin JIT-compiles kernels; the module's W^X lock makes
        # compile_model fail with "can't protect".
        MemoryDenyWriteExecute = lib.mkForce false;
      };
    };
  };
}
