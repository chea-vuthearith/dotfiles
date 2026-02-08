{self, ...}: {
  home.file.".test-self-path".text = "${self}";
}
