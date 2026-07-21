{pkgs, ...}: {
  programs.claude-code = {
    enable = true;
    lspServers = {
      ty = {
        command = "${pkgs.ty}/bin/ty";
        args = ["server"];
        extensionToLanguage = {
          ".py" = "python";
          ".pyi" = "python";
        };
      };
    };
  };
  programs.opencode = {
    enable = true;
    settings = {
      plugin = ["@mohak34/opencode-notifier@latest"];
    };
  };
}
