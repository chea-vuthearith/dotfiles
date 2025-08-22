{ config, lib, pkgs, inputs, ... }:

{
  imports = [ /etc/nixos/hardware-configuration.nix ];

  # Boot configuration
  boot = {
    kernelParams = [ "quiet" "mem_sleep_default=deep" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 3;
      systemd-boot.configurationLimit = 5;
    };
  };

  # Hardware settings
  hardware.i2c.enable = true;

  nixpkgs.config = { allowUnfree = true; };

  # Networking
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.enable = false;
    wg-quick.interfaces = {
      wg0 = {
        configFile = "/etc/wireguard/wg0.conf";
        autostart = false;
      };
    };

  };

  systemd.services.NetworkManager-wait-online.wantedBy = lib.mkForce [ ];

  # Time and locale
  time.timeZone = "Asia/Phnom_Penh";

  # Services
  services = {
    logind.powerKey = "ignore";
    openssh.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
    displayManager = {
      enable = true;
      ly = {
        enable = true;
        settings = {
          text_in_center = true;
          hide_version_string = true;
          hide_key_hints = true;
          hide_borders = true;
        };
      };
    };
    # getty = {
    #   helpLine = "";
    #   greetingLine = ''
    #       ______________________
    #     < i fucking hate my life >
    #       ----------------------
    #              \   ^__^
    #               \  (oo)\________
    #                 (__)\        )\/\\
    #                     ||----w |
    #                     ||     ||'';
    # };
  };

  # Virtualization
  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
    docker = {
      enable = true;
      enableOnBoot = false;
    };
  };

  # Security
  security.polkit.enable = true;

  # User configuration
  users = {
    users.kuro = {
      isNormalUser = true;
      extraGroups =
        [ "wheel" "video" "audio" "docker" "networkmanager" "libvrtd" ];
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
    };
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

  # DO NOT CHANGE
  system.stateVersion = "24.11";
}
