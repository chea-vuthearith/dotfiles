{...}: {
  flake.modules.homeManager.desktop = {
    pkgs,
    lib,
    config,
    ...
  }: let
    browserDir = "${config.xdg.configHome}/BraveSoftware/Brave-Origin";

    # brave://settings/system/shortcuts, stored per profile in Preferences as
    # brave.accelerators (command id -> keys, [] = disabled). Ids are Chromium's IDC_*.
    accelerators = {
      "33000" = ["Control+KeyO"]; # back (nvim jump list)
      "33001" = ["Control+KeyI"]; # forward
      "34016" = ["Control+PageDown" "Alt+KeyL"]; # next tab (herdr alt+l)
      "34017" = ["Control+PageUp" "Alt+KeyH"]; # previous tab (herdr alt+h)
      "34032" = ["Alt+Shift+KeyL"]; # move tab right (herdr alt+shift+l)
      "34033" = ["Alt+Shift+KeyH"]; # move tab left (herdr alt+shift+h)
      # defaults that shadow vim keys: ctrl+n new window, ctrl+d bookmark,
      # ctrl+u view source, ctrl+p print, ctrl+o open file, ctrl+h history,
      # ctrl+shift+o bookmark manager
      "34000" = [];
      "35000" = [];
      "35002" = [];
      "35003" = [];
      "40000" = [];
      "40010" = [];
      "40011" = [];
    };

    # Vimium C has no policy schema and keeps settings in LevelDB synced by Brave
    # Sync, so this is an import file: Vimium C options -> Import Settings.
    vimiumC = {
      name = "Vimium C";
      # the importer rejects a missing/near-zero time and would fall back to the file
      # mtime, which is 1 in the Nix store; any fixed date works (ms, 2026-10-18)
      time = 1792281600000;
      vimSync = true;
      keyLayout = 2;
      allBrowserUrls = true;
      grabBackFocus = true;
      hideHud = true;
      keyMappings = [
        "#!no-check"
        "unmap x"
        "unmap X"
        "unmap r"
        "unmap d"
        "unmap u"
        "unmap f"
        "unmap t"
        "unmap ge"
        ""
        "map <c-d> scrollPageDown"
        "map <c-u> scrollPageUp"
        "map go Vomnibar.activateEditUrl"
        # <space><tab>: same tab tree as nvim's <leader><tab>
        "map <space><tab><tab> createTab"
        "map <space><tab>o closeOtherTabs"
        "map <space><tab>h closeTabsOnLeft"
        "map <space><tab>l closeTabsOnRight"
        "map <space><tab>d removeTab"
        "map <space><space> Vomnibar.activateTabs"
        "map s LinkHints.activate"
      ];
      exclusionRules =
        map (pattern: {
          inherit pattern;
          passKeys = "";
        }) [
          ":https://mail.google.com/"
          ":https://excalidraw.com/"
          ":https://www.figma.com/"
          ":https://docs.google.com/"
          ":https://vscode.dev/"
          ":https://decrypt.day/"
          ":https://docs.groundup.ai/"
          "^https?://localhost:3000/"
          "^https?://localhost:8080/"
          "^https?://127\\.0\\.0\\.1:8082/"
        ];
      userDefinedCss = lib.removeSuffix "\n" (builtins.readFile ./vimium-c.css);
    };
  in {
    home.packages = [pkgs.brave-origin];

    xdg.configFile."vimium-c/settings.json".text = builtins.toJSON vimiumC;

    # Brave rewrites Preferences on exit, so edits while it runs are lost: skip then.
    # Only profiles Brave already initialised are touched (no Preferences = no-op).
    home.activation.braveAccelerators = lib.hm.dag.entryAfter ["writeBoundary"] ''
      braveDir=${lib.escapeShellArg browserDir}
      lock=$(readlink "$braveDir/SingletonLock" 2>/dev/null || true)
      if [[ -n $lock ]] && kill -0 "''${lock##*-}" 2>/dev/null; then
        warnEcho "Brave is running: shortcuts not applied, quit Brave and switch again"
      else
        for prefs in "$braveDir"/Default/Preferences "$braveDir"/Profile\ */Preferences; do
          [[ -f $prefs ]] || continue
          tmp=$(mktemp "$prefs.XXXXXX")
          if ${pkgs.jq}/bin/jq -c --argjson a ${lib.escapeShellArg (builtins.toJSON accelerators)} \
            'if .brave.accelerators then .brave.accelerators += $a else . end' "$prefs" >"$tmp" \
            && ! cmp -s "$tmp" "$prefs"; then
            run mv "$tmp" "$prefs"
          else
            rm -f "$tmp"
          fi
        done
      fi
    '';
  };
}
