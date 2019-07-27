#!/bin/sh
# shellcheck disable=SC2039



# Using unicode box drawings here.
# Note that we're truncating lines inside the box to 68 characters.
# Updated 2019-06-27.
_koopa_info_box() {
    local array
    local barpad

    array=("$@")
    barpad="$(printf "━%.0s" {1..70})"
    
    printf "\n  %s%s%s  \n"  "┏" "$barpad" "┓"
    for i in "${array[@]}"
    do
        printf "  ┃ %-68s ┃  \n"  "${i::68}"
    done
    printf "  %s%s%s  \n\n"  "┗" "$barpad" "┛"
}



# Updated 2019-06-22.
_koopa_is_darwin() {
    [ "$(uname -s)" = "Darwin" ]
}



# Updated 2019-06-27.
_koopa_is_installed() {
    local program
    program="$1"
    _koopa_quiet_which "$program"
}



# Updated 2019-06-21.
_koopa_is_interactive() {
    echo "$-" | grep -q "i"
}



# Updated 2019-06-21.
_koopa_is_linux() {
    [ "$(uname -s)" = "Linux" ]
}



# Updated 2019-06-24.
_koopa_is_linux_debian() {
    [ -f /etc/os-release ] || return 1
    grep "ID="      /etc/os-release | grep -q "debian" ||
    grep "ID_LIKE=" /etc/os-release | grep -q "debian"
}



# Updated 2019-06-24.
_koopa_is_linux_fedora() {
    [ -f /etc/os-release ] || return 1
    grep "ID="      /etc/os-release | grep -q "fedora" ||
    grep "ID_LIKE=" /etc/os-release | grep -q "fedora"
}



# Updated 2019-06-25.
_koopa_is_local() {
    echo "$KOOPA_HOME" | grep -Eq "^${HOME}"
}



# Updated 2019-06-21.
_koopa_is_login_bash() {
    [ "$0" = "-bash" ]
}



# Updated 2019-06-21.
_koopa_is_login_zsh() {
    [ "$0" = "-zsh" ]
}



# Updated 2019-06-25.
_koopa_is_remote() {
    [ -n "${SSH_CONNECTION:-}" ]
}



# Updated 2019-06-25.
_koopa_is_shared() {
    ! _koopa_is_local
}
