{...}: {
  flake.modules.homeManager.base = {pkgs, ...}: {
    home.packages = with pkgs; [
      lazydocker
      docker-compose
      docker-compose-language-service
      dockerfile-language-server
      hadolint
    ];
  };
}
