{ config, pkgs, ... }: {
  home.packages = with pkgs; [ flutter androidenv.androidPkgs.androidsdk ];
  nixpkgs.config.android_sdk.accept_license = true;
  home.sessionVariables = {
    ANDROID_HOME =
      "${pkgs.androidenv.androidPkgs.androidsdk}/libexec/android-sdk";
    ANDROID_AVD_HOME = "${config.xdg.configHome}/.android/avd";
  };
}
