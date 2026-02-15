{pkgs, ...}: {
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
      glib
      stdenv.cc.cc
    ];
  };
}
