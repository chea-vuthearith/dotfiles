{pkgs, ...}: {
  home.packages = with pkgs; [
    lazydocker
    docker
    docker-buildx
    docker-compose
    docker-compose-language-service
    dockerfile-language-server
    hadolint
  ];
}
