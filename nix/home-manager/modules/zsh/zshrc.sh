timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 10); do
    time $shell -i -c exit
  done
}

pfwd() {
  if [ $# -ne 2 ]; then
    echo "Usage: pfwd <port> <host>"
    return 1
  fi

  ssh -fNL "$1:localhost:$1" "$2"
}

init_keychain() {
  eval "$(keychain --quiet --eval id_ed25519)"
}

# Set cursor style
echo -ne '\e[6 q'
