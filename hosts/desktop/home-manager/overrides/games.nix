{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [mono umu-launcher];
  xdg.desktopEntries = {
    "Elden Ring" = {
      name = "Elden Ring";
      exec = ''
        sh -c "xrandr --output DP-3 --primary && WINEDLLOVERRIDES='dinput8.dll=n,b;d3dcompiler_47=n;dxgi=n,b' umu-run '${config.home.homeDirectory}/Games/Elden Ring/Game/eldenring.exe'"'';
      categories = ["Game"];
      icon = "${config.home.homeDirectory}/Games/Elden Ring/Game/EasyAntiCheat/splashscreen.png";
    };
  };
}
