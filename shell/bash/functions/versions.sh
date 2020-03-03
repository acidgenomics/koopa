#!/usr/bin/env bash

_koopa_check_version() {  # {{{1
    # """
    # Check that program is installed and passes minimum version.
    # @note Updated 2020-03-03.
    #
    # How to break a loop with an error code:
    # https://stackoverflow.com/questions/14059342/
    # """
    local current
    IFS='.' read -r -a current <<< "${1:?}"

    local expected
    IFS='.' read -r -a expected <<< "${2:?}"

    local status
    status=0
    for i in "${!current[@]}"
    do
        if [ ! "${current[$i]}" -ge "${expected[$i]}" ]
        then
            status=1
            break
        fi
    done

    return "$status"
}

