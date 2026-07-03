genpass() {
  local length="${1:-64}"
  local charset="a-z0-9"

  if [[ "$2" == "--upper" || "$2" == "-u" ]]; then
    charset="A-Za-z0-9"
  fi

  LC_ALL=C tr -dc "$charset" < /dev/urandom | head -c "$length"
  echo
}
