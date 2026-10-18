{
  # Public stand-in for the private `secrets` input, for machines that cannot
  # reach GitHub over SSH yet (fresh installs). Used by scripts/bootstrap.sh via
  # `--override-input secrets`. `bootstrap = true` makes modules/base/secrets.nix
  # skip sops validation and decryption; sops consumers start after the first real `nsw`.
  description = "Empty stand-in for the private secrets flake";
  outputs = _: {
    sshConfig = "";
    sopsFile = ./secrets.yaml;
    bootstrap = true;
  };
}
