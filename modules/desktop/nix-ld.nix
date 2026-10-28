{...}: {
  flake.modules.nixos.desktop = {
    pkgs,
    lib,
    ...
  }: let
    pkgs32 = pkgs.pkgsi686Linux;
  in {
    # 32-bit loader (/lib/ld-linux.so.2) for i686 binaries such as Proton's wine.
    environment.ldso32 = "${pkgs32.nix-ld}/libexec/nix-ld";
    environment.sessionVariables = {
      NIX_LD_i686_linux = pkgs32.stdenv.cc.bintools.dynamicLinker;
      NIX_LD_LIBRARY_PATH_i686_linux = lib.makeLibraryPath (with pkgs32; [
        stdenv.cc.cc.lib
        zlib
        glib
        libGL
        libxcb
        libx11
        freetype
        fontconfig
        alsa-lib
        libpulseaudio
        wayland
        libxkbcommon
      ]);
    };
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        wayland
        wayland-protocols
        libxkbcommon
        alsa-lib
        libpulseaudio
        pipewire
        icu
        libxcb
        zlib
        libGL
        stdenv.cc.cc.lib
        glib
      ];
    };
  };
}
