{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
    inputs.home-manager.nixosModules.default
  ];

  # Boot configuration
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelModules = [ "hid_apple" ];
    extraModprobeConfig = ''
      options hid_apple fnmode=2
    '';
  };

  # Hardware settings
  hardware.i2c.enable = true;

  # Networking
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  # Time and locale
  time.timeZone = "Asia/Phnom_Penh";

  # Services
  services = {
    upower.enable = true;
    openssh.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };

  # Virtualization
  virtualisation.docker.enable = true;

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
  environment.systemPackages = with pkgs; [
    neovim
    wget
    dconf
    # fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
  ];

  # Miscellaneous
  services.getty.greetingLine = ''
      ______________
    < i hate my life >
      --------------
             \   ^__^ 
              \  (oo)\_______
                (__)\       )\/\\
                    ||----w |
                    ||     ||'';
  # DO NOT CHANGE
  system.stateVersion = "24.11";

  # Home Manager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = { kuro = import ./home.nix; };
  };
}
