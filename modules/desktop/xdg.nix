{...}: {
  flake.modules.homeManager.desktop = {
    pkgs,
    lib,
    ...
  }: let
    forTypes = app: types: lib.genAttrs types (_: app);
    images = forTypes "swappy.desktop" (map (t: "image/${t}") ["avif" "bmp" "gif" "jpeg" "png" "svg+xml" "webp"]);
    videos = forTypes "mpv.desktop" (map (t: "video/${t}") ["avi" "mp4" "mpeg" "quicktime" "webm" "x-matroska" "x-msvideo"]);
    files = forTypes "yazi.desktop" ["inode/directory" "x-scheme-handler/file"];
    telegram = forTypes "org.telegram.desktop.desktop" ["x-scheme-handler/tg" "x-scheme-handler/tonsite"];
    browser = forTypes "brave-origin.desktop" (
      ["text/html"] ++ map (s: "x-scheme-handler/${s}") ["about" "http" "https" "unknown"]
    );
  in {
    xdg = {
      enable = true;
      portal = {
        extraPortals = [pkgs.xdg-desktop-portal-termfilechooser];
        config.common = {
          "org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
        };
      };
      configFile."xdg-desktop-portal-termfilechooser/config" = {
        force = true;
        text = ''
          [filechooser]
          cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
          create_help_file=0
          env=TERMCMD=ghostty -e
          default_dir=$HOME
          open_mode=suggested
          save_mode=last
        '';
      };
      # Replaces the hand-edited mimeapps.list; apps can no longer change defaults at runtime.
      mimeApps = {
        enable = true;
        defaultApplications =
          images
          // videos
          // files
          // telegram
          // browser
          // {"x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";};
        associations.added = images // videos // files // telegram;
      };
      configFile."mimeapps.list".force = true;
      dataFile."applications/mimeapps.list".force = true;
      userDirs = {
        enable = true;
        createDirectories = true;
        setSessionVariables = true;
      };
    };
  };
}
