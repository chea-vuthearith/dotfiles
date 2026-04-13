{pkgs, ...}: {
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
    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
    };
  };
}
