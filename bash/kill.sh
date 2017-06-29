# Kill all running bsub requests
command -v bkill >/dev/null 2>&1 || { echo >&2 "bkill missing"; exit 1; }
bkill 0
