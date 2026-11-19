# Tern: Stencil's terminal. Closed source; every build.stencil.so download (the updater's too)
# needs a Stencil login, so the tarball comes from requireFile. It lives in the server's store
# (pinned below, served by its harmonia cache to the LAN). To bump: download the Linux x86_64
# build from https://build.stencil.so/tern, update version + sha256 below, run
# `nix-store --add-fixed sha256 tern.tar.gz` on the server, then `nsw` there.
# Tern's self-updater cannot write to the store; updates come through this file.
{...}: {
  # overlay on every host so the server can pin the src
  flake.modules.nixos.base = {...}: {
    nixpkgs.overlays = [
      (final: _prev: {
        tern = final.stdenv.mkDerivation (finalAttrs: {
          pname = "tern";
          version = "0.9.28";
          src = final.requireFile {
            name = "tern.tar.gz";
            sha256 = "1m4dsdiz1r62yk0p6ixxpzyyi3ik68jnzal0fad847fapyms68l3";
            message = ''
              Tern ${finalAttrs.version} is behind a Stencil login. Download the Linux x86_64
              build from https://build.stencil.so/tern, then on the server run:
                nix-store --add-fixed sha256 tern.tar.gz
              and `nsw` it (the desktop and laptop substitute it from server.local).
            '';
          };
          sourceRoot = "tern";
          nativeBuildInputs = [final.autoPatchelfHook final.copyDesktopItems];
          buildInputs = [final.stdenv.cc.cc.lib];
          # dlopen'd at runtime; put on RUNPATH, not LD_LIBRARY_PATH (which would leak into shells)
          runtimeDependencies = with final; [
            vulkan-loader
            libGL
            pam
            libpulseaudio
            wayland
            libxcb
            libxkbcommon
            webkitgtk_4_1
          ];

          dontStrip = true;
          installPhase = ''
            runHook preInstall
            install -Dm755 tern $out/bin/tern
            runHook postInstall
          '';

          desktopItems = [
            (final.makeDesktopItem {
              name = "tern";
              desktopName = "Tern";
              comment = "A multiplexing terminal";
              exec = "tern %F";
              icon = "utilities-terminal";
              categories = ["System" "TerminalEmulator"];
            })
          ];
          meta = {
            description = "Stencil's multiplexing terminal";
            homepage = "https://build.stencil.so/tern";
            license = final.lib.licenses.unfree;
            sourceProvenance = [final.lib.sourceTypes.binaryNativeCode];
            platforms = ["x86_64-linux"];
            mainProgram = "tern";
          };
        });
      })
    ];
  };

  # keep the tarball in the server's system closure: never garbage-collected, always served
  flake.modules.nixos.host-server = {pkgs, ...}: {
    system.extraDependencies = [pkgs.tern.src];
  };

  flake.modules.nixos.desktop = {...}: {
    # WebKitGTK in browser blocks needs glib-networking for TLS ("TLS support is not available").
    services.gnome.glib-networking.enable = true;
  };

  flake.modules.homeManager.desktop = {pkgs, ...}: {
    home.packages = [pkgs.tern];
  };
}
