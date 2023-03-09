#!/usr/bin/env bash

__koopa_ansi_escape() {
    # """
    # ANSI escape codes.
    # @note Updated 2020-07-05.
    # """
    local escape
    case "${1:?}" in
        'nocolor')
            escape='0'
            ;;
        'default')
            escape='0;39'
            ;;
        'default-bold')
            escape='1;39'
            ;;
        'black')
            escape='0;30'
            ;;
        'black-bold')
            escape='1;30'
            ;;
        'blue')
            escape='0;34'
            ;;
        'blue-bold')
            escape='1;34'
            ;;
        'cyan')
            escape='0;36'
            ;;
        'cyan-bold')
            escape='1;36'
            ;;
        'green')
            escape='0;32'
            ;;
        'green-bold')
            escape='1;32'
            ;;
        'magenta')
            escape='0;35'
            ;;
        'magenta-bold')
            escape='1;35'
            ;;
        'red')
            escape='0;31'
            ;;
        'red-bold')
            escape='1;31'
            ;;
        'yellow')
            escape='0;33'
            ;;
        'yellow-bold')
            escape='1;33'
            ;;
        'white')
            escape='0;97'
            ;;
        'white-bold')
            escape='1;97'
            ;;
        *)
            return 1
            ;;
    esac
    printf '\033[%sm' "$escape"
    return 0
}
