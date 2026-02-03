{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [flutter android-studio android-tools];

  home.sessionVariables = {
    ANDROID_HOME = "${config.home.homeDirectory}/Android/Sdk";
    ANDROID_SDK_ROOT = "${config.home.homeDirectory}/Android/Sdk";
  };
}
