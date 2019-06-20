#!/usr/bin/env bash

# Show koopa installation information (in a box).
# Modified 2019-06-12.

quiet_command() {
    command -v "$1" 2>/dev/null
}

array=()
array+=("$(koopa --version)")
array+=("https://github.com/acidgenomics/koopa")

array+=("")

array+=("## System information")
array+=("OS: $(python -mplatform)")
array+=("Current shell: ${KOOPA_SHELL}")
array+=("Default shell: ${SHELL}")
array+=("Install path: $KOOPA_DIR")

array+=("")

array+=("## Dependencies")

locate() {
    local command="$1"
    local name="${2:-$command}"
    local path="$(quiet_command "$command")"
    if [[ -z "$path" ]]
    then
        path="[missing]"
    else
        path="$(realpath "$path")"
    fi
    printf "%s: %s" "$name" "$path"
}

array+=("$(locate bash Bash)")
array+=("$(locate R)")
array+=("$(locate python Python)")

unset -f locate

array+=("")
array+=("Run 'koopa check' to verify installation.")

# Using unicode box drawings here.
# Note that we're truncating lines inside the box to 68 characters.
barpad="$(printf "━%.0s" {1..70})"
printf "\n  %s%s%s  \n"  "┏" "$barpad" "┓"
for i in "${array[@]}"
do
    printf "  ┃ %-68s ┃  \n"  "${i::68}"
done
printf "  %s%s%s  \n\n"  "┗" "$barpad" "┛"

unset -v array barpad
