{ pkgs, ... }: {
  pkgs.androidenv.emulateApp = {
    name = "test";
    platformVersion = "35"; # Android API level (e.g., 35 for Android 15)
    abiVersion = "x86_64"; # Architecture
    systemImageType = "google_apis"; # Type of system image
    enableGPU = true;
    device = "pixel_8_pro"; # Target device profile
  };
}
