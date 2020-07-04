#!/usr/bin/env bash

koopa::check_version() { # {{{1
    # """
    # Check that program is installed and passes minimum version.
    # @note Updated 2020-06-29.
    #
    # How to break a loop with an error code:
    # https://stackoverflow.com/questions/14059342/
    # """
    koopa::assert_has_args "$#"
    local current expected status
    IFS='.' read -r -a current <<< "${1:?}"
    IFS='.' read -r -a expected <<< "${2:?}"
    status=0
    for i in "${!current[@]}"
    do
        if [[ ! "${current[$i]}" -ge "${expected[$i]}" ]]
        then
            status=1
            break
        fi
    done
    return "$status"
}

