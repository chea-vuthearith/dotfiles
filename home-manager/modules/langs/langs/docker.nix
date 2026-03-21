{pkgs, ...}: {
  home.packages = with pkgs; [
    docker
    docker-buildx
    docker-compose
    docker-compose-language-service
    dockerfile-language-server
    hadolint
  ];
}
