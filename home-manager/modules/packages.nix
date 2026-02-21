{pkgs, ...}: {
  programs = {
    opencode.enable = true;
    mpv.enable = true;
    chromium = {
      enable = true;
      package = pkgs.brave;
      commandLineArgs = [
        "--hide-crash-restore-bubble"
        "--test-type"
        "-enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
      ];
    };
  };
  home.packages = with pkgs; [
    gcc
    libgcc
    newt
    gnumake
    gnused
    lua
    openjdk
    rustc
    cargo
    python3
    nodejs_24
    pnpm_10
    turbo
    sqlite
    postgresql
    uv
    anydesk
    aria2
    jq
    glib
    xdg-user-dirs
    zip
    unzip
    unrar
    bottom
    openssl
    lsd
    libgtop
    xh
    docker
    docker-buildx
    docker-compose
    magic-wormhole
    mqttx
    redis
    ffmpeg
    imagemagick
    playerctl
    tesseract
    wf-recorder
    swappy
    hyprpicker
    mesa
    linux-firmware
    libnotify
    pavucontrol
    brightnessctl
    dragon-drop
    hyprpaper
    abiword
    discord
    telegram-desktop
    grim
    slurp
    wl-clipboard
  ];
}
