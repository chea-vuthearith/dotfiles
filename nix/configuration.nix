# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ config, lib, pkgs, inputs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    /etc/nixos/hardware-configuration.nix
    inputs.home-manager.nixosModules.default
  ];

  hardware.i2c.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelModules = [ "hid_apple" ];

  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Phnom_Penh";

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.upower.enable = true;

  users.users.kuro = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "docker" ];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
  };

  virtualisation.docker.enable = true;

  programs.zsh.enable = false;
  programs.hyprland.enable = true;
  environment.systemPackages = with pkgs; [
    neovim
    wget
    dconf
    # fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
  ];

  services.openssh.enable = true;
  # DO NOT CHANGE
  system.stateVersion = "24.11";

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = { kuro = import ./home.nix; };
  };

}

