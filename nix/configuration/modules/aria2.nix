{ username, ... }: {
  services.aria2 = {
    enable = true;
    settings = {
      enable-rpc = true;
      resume = true;
    };
    rpcSecretFile = "/home/${username}/.aria2secret";
  };
  logind.settings.Login.HandlePowerKey = "ignore";
  pipewire = {
    enable = true;
    pulse.enable = true;
  };

}
