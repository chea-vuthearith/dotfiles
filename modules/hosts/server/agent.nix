{lib, ...}: {
  flake.modules.homeManager.host-server = {...}: {
    # Use the agent forwarded over SSH; keychain and a local ssh-agent would both
    # replace SSH_AUTH_SOCK and hide it.
    programs.keychain.enable = lib.mkForce false;
    services.ssh-agent.enable = lib.mkForce false;
  };
}
