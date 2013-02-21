ANSI_RED="\033[31m"
ANSI_GREEN="\033[32m"
ANSI_YELLOW="\033[33m"
ANSI_BLUE="\033[34m"
ANSI_RESET="\033[0m"
ANSI_BOLD="\033[1m"

status () {
  echo "${ANSI_BLUE}---> ${@}${ANSI_RESET}" >&2
}

ok () {
  echo "${ANSI_GREEN}${ANSI_BOLD}OK:${ANSI_RESET} ${ANSI_GREEN}${@}${ANSI_RESET}" >&2
}

error () {
  echo "${ANSI_RED}${ANSI_BOLD}ERROR:${ANSI_RESET} ${ANSI_RED}${@}${ANSI_RESET}" >&2
}

warning () {
  echo "${ANSI_YELLOW}${ANSI_BOLD}WARNING:${ANSI_RESET} ${ANSI_YELLOW}${@}${ANSI_RESET}" >&2
}

report () {
    status=$?
    if [ $status -ne 0 ] ; then
        error "failed" 
        exit $status
    fi
    ok "succeeded."
}

trap "report" EXIT
