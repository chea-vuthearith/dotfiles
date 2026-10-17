{...}: {
  flake.modules.homeManager.base = {
    pkgs,
    lib,
    osConfig,
    ...
  }: let
    self = osConfig.networking.hostName;

    # Tailscale SSH targets (MagicDNS names). Each host lists every other one.
    devices = ["desktop" "laptop" "server"];
    # Work hosts only make sense where an agent can authenticate (not the headless server).
    extra = lib.optionals (self != "server") ["GroundupDev"];

    machine = target: {
      # herdr wants an opaque 32-hex id; derive it so it stays stable across rebuilds.
      id = builtins.substring 0 32 (builtins.hashString "sha256" "herdr-machine-${target}");
      label = target;
      inherit target;
      session = "default";
      enabled = true;
    };

    endpoints = pkgs.writeText "herdr-endpoints.json" (builtins.toJSON {
      version = 1;
      ssh = map machine (lib.remove self devices ++ extra);
    });
  in {
    # herdr rewrites this file (machine add/rename/disable), so it is copied, not
    # symlinked: each switch resets it to the declared list.
    home.activation.herdrMachines = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run install -Dm600 ${endpoints} "$HOME/.local/state/herdr/client/endpoints.json"
    '';
  };
}
