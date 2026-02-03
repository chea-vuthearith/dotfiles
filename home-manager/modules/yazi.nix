{pkgs, ...}: {
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
        run = ''shell -- dragon-drop -x -i -a -T "$@"'';
      }
      {
        on = "y";
        run = [
          ''
            shell -- for path in "$@"; do echo "file://$path"; done | wl-copy -t text/uri-list''
          "yank"
        ];
      }
      {
        on = "P";
        run = "shell -- wl-paste > pasted-image.png";
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
}
