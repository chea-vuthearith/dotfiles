{config, ...}: let
  inherit (config) username;
in {
  # One bot (@cheaserverbot) shared by every host: it only sends, so no getUpdates conflict.
  flake.modules.nixos.base = {
    sops.secrets.telegram-bot-token.owner = username;
  };
  # omp `telegram` tool: urgent blocking pings, only while kuro is away (see the .ts header).
  flake.modules.homeManager.base = {
    pkgs,
    lib,
    osConfig,
    ...
  }: {
    home.file.".omp/agent/extensions/telegram.ts".source = pkgs.replaceVars ./omp/extensions/telegram.ts {
      tokenFile = osConfig.sops.secrets.telegram-bot-token.path;
      chatId = "1176935257"; # kuro's user id (= private chat id); not secret
      # lid closed = away, only on the laptop; the server is an old laptop that stays shut
      checkLid = lib.boolToString (osConfig.networking.hostName == "laptop");
    };
  };
}
