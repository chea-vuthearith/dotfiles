{config, ...}: let
  inherit (config) username;
in {
  # One bot (@cheaserverbot) shared by every host: it only sends, so no getUpdates conflict.
  flake.modules.nixos.base = {
    sops.secrets.telegram-bot-token.owner = username;
  };
  # omp extension: long root-session turns end with a Telegram message to kuro's chat.
  flake.modules.homeManager.base = {
    pkgs,
    osConfig,
    ...
  }: {
    home.file.".omp/agent/extensions/telegram-notify.ts".source = pkgs.replaceVars ./omp/extensions/telegram-notify.ts {
      tokenFile = osConfig.sops.secrets.telegram-bot-token.path;
      chatId = "1176935257"; # kuro's user id (= private chat id); not secret
      minTurnMs = toString (2 * 60 * 1000);
    };
  };
}
