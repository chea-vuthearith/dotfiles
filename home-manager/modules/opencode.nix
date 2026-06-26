{pkgs, ...}: {
  programs.claude-code = {
    enable = true;
  };
  programs.opencode = {
    enable = true;
    settings = {
      plugin = ["@mohak34/opencode-notifier@latest"];
    };
  };
}
