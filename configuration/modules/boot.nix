{pkgs, ...}: {
  services.logind.settings.Login.HandlePowerKey = "ignore";
  boot = {
    # Silent boot configuration
    kernelParams = [
      "quiet"
      "splash"
      "vga=current"
      "rd.systemd.show_status=auto"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "boot.shell_on_fail"
    ];
    consoleLogLevel = 3;
    initrd.verbose = false;
    loader = {
      systemd-boot.enable = false;
      grub = {
        theme = pkgs.stdenv.mkDerivation {
          name = "particle-grub-theme";
          src = pkgs.fetchFromGitHub {
            owner = "yeyushengfan258";
            repo = "Particle-grub-theme";
            rev = "9515def4f174281c6eda005b911028d4f6ae7d83";
            sha256 = "sha256-XEQ/S7e5T9XhkuEmpmSnI5OyhMUdEI+MXnQ+0oTHeUs=";
          };
          installPhase = ''
            mkdir -p $out
            cd $out
            cp $src/config/theme-sidebar-1080p.txt theme.txt
            cp $src/backgrounds/backgrounds/background-sidebar.jpg background.jpg
            cp -r $src/assets/assets-icons/icons-1080p icons
            cp $src/assets/assets-other/other-1080p/select_*.png .
            cp $src/assets/assets-other/other-1080p/sidebar.png info.png
            cp $src/common/*.pf2 .
          '';
        };
        enable = true;
        configurationLimit = 3;
        device = "nodev";
        default = "saved";
        useOSProber = true;
        efiSupport = true;
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      timeout = 0;
    };
    plymouth = {
      enable = true;
    };
  };
}
