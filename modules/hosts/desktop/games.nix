{...}: {
  flake.modules.nixos.host-desktop = {...}: {
    security.pam.loginLimits = [
      {
        domain = "*";
        type = "soft";
        item = "memlock";
        value = "unlimited";
      }
      {
        domain = "*";
        type = "hard";
        item = "memlock";
        value = "unlimited";
      }
    ];
  };
  flake.modules.homeManager.host-desktop = {pkgs, ...}: let
    monkeylauncher = pkgs.stdenv.mkDerivation {
      pname = "monkeylauncher";
      version = "0.5.4";
      src = pkgs.fetchFromGitHub {
        owner = "SaruM4N3";
        repo = "MonkeyLauncher";
        rev = "02151d361a44ae14d647f5ba221f6f861e9020e9";
        hash = "sha256-TIyQx53dtxeFVSkNC95Nvr/pWK1PdV2PYUQLdxSyFrs=";
      };
      nativeBuildInputs = with pkgs; [pkg-config makeWrapper];
      buildInputs = with pkgs; [gtkmm3 curl nlohmann_json];
      makeFlags = ["PREFIX=$(out)"];
      # Runtime tools the GUI and CLI spawn by name.
      postFixup = let
        path = pkgs.lib.makeBinPath (with pkgs; [
          umu-launcher
          winetricks
          protontricks
          fzf
          procps
          xdg-utils
          mangohud
        ]);
      in ''
        wrapProgram $out/lib/monkeylauncher/monkeylauncher --prefix PATH : ${path}
        wrapProgram $out/bin/MonkeyLauncherCLI --prefix PATH : ${path}
      '';
    };
  in {
    home.packages = with pkgs; [
      mono
      steam
      monkeylauncher
      # rpcs3
      # SDL2
    ];
  };
}
