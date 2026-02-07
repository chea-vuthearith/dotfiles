{pkgs, ...}: {
  programs.nix-ld = {
    libraries = with pkgs; [
      alsa-lib
      libpulseaudio
      pipewire
      icu
    ];
    enable = true;
  };
}
