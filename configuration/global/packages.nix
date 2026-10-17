{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    sshpass
  ];
}
