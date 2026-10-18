{config, ...}: let
  # Tailscale SSH targets (MagicDNS names = host names). Each host lists every other one.
  devices = builtins.attrNames config.hosts;
in {
  flake.modules.homeManager.base = {
    pkgs,
    lib,
    osConfig,
    ...
  }: let
    self = osConfig.networking.hostName;
    others = lib.remove self devices;

    # Local session -> saved machines. session-machines.patch scopes herdr's machine
    # catalog per local session, so each one only connects to what is listed here.
    sessions = {
      default = map (target: {inherit target;}) others;
      personal =
        map (target: {
          inherit target;
          session = "personal";
        })
        others;
    };

    machine = {
      target,
      session ? "default",
      enabled ? true,
    }: {
      # herdr wants an opaque 32-hex id; derive it so it stays stable across rebuilds.
      id = builtins.substring 0 32 (builtins.hashString "sha256" (
        if session == "default"
        then "herdr-machine-${target}"
        else "herdr-machine-${target}-${session}"
      ));
      label = target;
      inherit target session enabled;
    };

    catalogDir = name:
      if name == "default"
      then "$HOME/.local/state/herdr/client"
      else "$HOME/.local/state/herdr/client/sessions/${name}";

    install = name: machines: let
      endpoints = pkgs.writeText "herdr-endpoints-${name}.json" (builtins.toJSON {
        version = 1;
        ssh = map machine machines;
      });
    in ''run install -Dm600 ${endpoints} "${catalogDir name}/endpoints.json"'';
  in {
    # herdr rewrites these files (machine add/rename/disable), so they are copied, not
    # symlinked: each switch resets them to the declared lists.
    home.activation.herdrMachines = lib.hm.dag.entryAfter ["writeBoundary"] (
      lib.concatStringsSep "\n" (lib.mapAttrsToList install sessions)
    );
  };
}
