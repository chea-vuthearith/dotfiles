{username, ...}: {
  users.users.${username}.limits.memlock = 2097152; # 2 GiB
}
