{ config, lib, pkgs, inputs, ... }:

{
  imports = [ /etc/nixos/hardware-configuration.nix ];

  # Boot configuration
  boot = {
    kernelParams = [ "quiet" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 3;
      systemd-boot.configurationLimit = 5;
    };
  };

  # Hardware settings
  hardware.i2c.enable = true;
  hardware.graphics.enable = true;

  # Networking
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.enable = false;
  };

  systemd.services.NetworkManager-wait-online.wantedBy = lib.mkForce [ ];

  # Time and locale
  time.timeZone = "Asia/Phnom_Penh";

  # Services
  services = {
    logind.powerKey = "ignore";
    xserver.videoDrivers = [ "modesetting" ];
    openssh.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };

  # Virtualization
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  # Security
  security.polkit.enable = true;

  # User configuration
  users.users.kuro = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "docker" "networkmanager" ];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
  };

  # Programs
  programs = {
    zsh.enable = false;
    hyprland.enable = true;
    nix-ld.enable = true;
  };

  # Environment
  environment.systemPackages = with pkgs; [ neovim wget dconf dbus ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    nerd-fonts.fira-code
    nerd-fonts.victor-mono
  ];

  # Miscellaneous
  services.getty.helpLine = "";
  services.getty.greetingLine = ''
      ______________________
    < i fucking hate my life >
      ----------------------
             \   ^__^ 
              \  (oo)\________
                (__)\        )\/\\
                    ||----w |
                    ||     ||'';
  # DO NOT CHANGE
  system.stateVersion = "24.11";
}
