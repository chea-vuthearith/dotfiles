{pkgs, ...}: {
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      alsa-lib
      libpulseaudio
      pipewire
      icu
    ];
  };
}
