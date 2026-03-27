{...}: {
  security.pam.loginLimits = [
    {
      domain = "*"; # replace with your user
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
}
