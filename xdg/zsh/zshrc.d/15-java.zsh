# Java: prefer the macOS Java registry when JDK 21 has been registered.
if [[ -z "${JAVA_HOME:-}" && "$(uname -s)" == "Darwin" && -x /usr/libexec/java_home ]]; then
  java_home_21="$(/usr/libexec/java_home -v 21 2>/dev/null)"
  if [[ -n "$java_home_21" ]]; then
    export JAVA_HOME="$java_home_21"
  fi
  unset java_home_21
fi
