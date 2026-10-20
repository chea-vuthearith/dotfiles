{
  # One nginx front door for the .internal names over TLS on :443 (Frigate's
  # module already runs nginx; this reuses it rather than adding a second proxy).
  #   frigate.internal   -> Frigate UI   (127.0.0.1:5000, its own vhost)
  #   hindsight.internal -> Hindsight UI (tailnet IP :9999)
  # TLS is a self-signed cert generated once by openssl (a public CA cannot
  # issue for .internal). Trust it per client: copy /etc/nginx/internal.crt.
  flake.modules.nixos.host-server = {
    lib,
    pkgs,
    ...
  }: let
    # Hindsight publishes its ports on the tailnet IP (hindsight.nix), not
    # loopback, so nginx proxies to that address; the host itself can reach it.
    tailnetIp = "100.93.89.8";
    cert = "/etc/nginx/internal.crt";
    key = "/etc/nginx/internal.key";
    names = ["frigate.internal" "hindsight.internal"];
  in {
    # Generate the cert on first boot and fix ownership/permissions on every
    # activation. nginx runs as the `nginx` user (its ExecStartPre config test
    # too), so the key must be readable by it: owned nginx:nginx, mode 0640.
    systemd.services.nginx-selfsigned-cert = {
      description = "Self-signed TLS certificate for *.internal";
      wantedBy = ["multi-user.target"];
      before = ["nginx.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        if [ ! -e ${cert} ]; then
          ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:2048 -nodes -days 3650 \
            -keyout ${key} -out ${cert} \
            -subj "/CN=${builtins.head names}" \
            -addext "subjectAltName=${lib.concatMapStringsSep "," (n: "DNS:${n}") names}"
        fi
        chown nginx:nginx ${cert} ${key}
        chmod 0644 ${cert}
        chmod 0640 ${key}
      '';
    };

    # nginx must wait for (and pull in) the cert, not merely be ordered after it,
    # so a fresh deploy can never start nginx before the cert exists.
    systemd.services.nginx = {
      requires = ["nginx-selfsigned-cert.service"];
      after = ["nginx-selfsigned-cert.service"];
    };

    services.nginx.virtualHosts = {
      "frigate.internal" = {
        onlySSL = true;
        sslCertificate = cert;
        sslCertificateKey = key;
        extraConfig = ''
          location / {
            proxy_pass http://127.0.0.1:5000;
            proxy_set_header Host $host;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
          }
        '';
      };
      "hindsight.internal" = {
        onlySSL = true;
        sslCertificate = cert;
        sslCertificateKey = key;
        extraConfig = ''
          location / {
            proxy_pass http://${tailnetIp}:9999;
            proxy_set_header Host $host;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
          }
        '';
      };
    };

    # HTTPS from the LAN and the tailnet only.
    networking.firewall.extraInputRules = ''
      ip saddr 192.168.0.0/24 tcp dport 443 accept
      ip saddr 100.64.0.0/10 tcp dport 443 accept
    '';
  };
}
