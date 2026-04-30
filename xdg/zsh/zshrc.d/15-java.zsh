# Java: prefer the macOS Java registry when JDK 25 has been registered.
if [[ -z "${JAVA_HOME:-}" && "$(uname -s)" == "Darwin" && -x /usr/libexec/java_home ]]; then
  java_home_25="$(/usr/libexec/java_home -F -v 25 2>/dev/null)"
  if [[ -n "$java_home_25" ]]; then
    export JAVA_HOME="$java_home_25"
  fi
  unset java_home_25
fi
