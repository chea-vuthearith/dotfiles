{...}: {
  flake.modules.homeManager.desktop = {pkgs, ...}: let
    # Terminal multiplexers (herdr) may outlive or predate the graphical session
    # and lack WAYLAND_DISPLAY/DISPLAY; pull them from the systemd user manager.
    gui = pkgs.writeShellScript "yazi-gui-env" ''
      eval "$(${pkgs.systemd}/bin/systemctl --user show-environment \
        | ${pkgs.gnugrep}/bin/grep -E '^(WAYLAND_DISPLAY|DISPLAY)=' \
        | ${pkgs.gnused}/bin/sed 's/^/export /')"
      exec "$@"
    '';
  in {
    home.packages = [pkgs.dragon-drop]; # <C-n> below
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      keymap.mgr.prepend_keymap = [
        {
          on = "i";
          run = "spot";
        }
        {
          on = ["g" "r"];
          run = ''shell -- ya emit cd "$(git rev-parse --show-toplevel)"'';
          desc = "Go to git root";
        }
        {
          on = "<C-n>";
          run = ''shell -- ${gui} dragon-drop -x -i -a -T "$@"'';
        }
        {
          on = "y";
          run = [
            ''
              shell -- for path in "$@"; do echo "file://$path"; done | ${gui} wl-copy -t text/uri-list''
            "yank"
          ];
        }
        {
          on = "P";
          run = "shell -- ${gui} wl-paste > pasted-image.png";
          desc = "Paste image from clipboard";
        }
        {
          on = "z";
          run = "plugin zoxide";
        }
        {
          run = "quit";
          on = ["Z" "Z"];
        }
        {
          on = "<Down>";
          run = ["seek 1"];
        }
        {
          on = "<Up>";
          run = ["seek -1"];
        }
      ];
      settings = {
        mgr.show_hidden = true;
        preview.max_width = 1600;
        preview.max_height = 1440;
      };
      shellWrapperName = "y";
    };
  };
}
