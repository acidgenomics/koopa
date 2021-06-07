#!/usr/bin/env bash

koopa:::int_to_yn() { # {{{1
    # """
    # Convert integer to yes/no choice.
    # @note Updated 2020-07-02.
    # """
    local x
    koopa::assert_has_args_eq "$#" 1
    case "${1:?}" in
        0)
            x='no'
            ;;
        1)
            x='yes'
            ;;
        *)
            koopa::stop 'Invalid choice: requires 0 or 1.'
            ;;
    esac
    koopa::print "$x"
    return 0
}

koopa:::read_prompt_yn() { # {{{1
    # """
    # Show colorful yes/no default choices in prompt.
    # @note Updated 2020-07-20.
    # """
    local no no_default prompt yes yes_default yn
    koopa::assert_has_args_eq "$#" 2
    no="$(koopa::print_red 'no')"
    no_default="$(koopa::print_red_bold 'NO')"
    yes="$(koopa::print_green 'yes')"
    yes_default="$(koopa::print_green_bold 'YES')"
    prompt="${1:?}"
    case "${2:?}" in
        0)
            yn="${yes}/${no_default}"
            ;;
        1)
            yn="${yes_default}/${no}"
            ;;
        *)
            koopa::stop 'Invalid choice: requires 0 or 1.'
            ;;
    esac
    koopa::print "${prompt}? [${yn}]: "
    return 0
}

koopa::read() { # {{{1
    # """
    # Read a string from the user.
    # @note Updated 2020-07-02.
    # """
    local choice default flags prompt
    koopa::assert_has_args_eq "$#" 2
    default="${2:?}"
    prompt="${1:?} [${default}]: "
    flags=(-r -p "$prompt")
    if ! koopa::is_bash_ok
    then
        flags+=(-e -i "${koopa_prefix}")
    fi
    # shellcheck disable=SC2162
    read "${flags[@]}" choice
    choice="${choice:-$default}"
    koopa::print "$choice"
    return 0
}

koopa::read_yn() { # {{{1
    # """
    # Read a yes/no choice from the user.
    # @note Updated 2020-07-02.
    #
    # Checks if Bash version is ancient (e.g. macOS clean install), so we can
    # adjust interactive read input flags accordingly.
    # """
    local choice default flags x
    koopa::assert_has_args_eq "$#" 2
    prompt="$(koopa:::read_prompt_yn "$@")"
    default="$(koopa:::int_to_yn "${2:?}")"
    flags=(-r -p "$prompt")
    if koopa::is_bash_ok
    then
        flags+=(-e -i "$default")
    fi
    # shellcheck disable=SC2162
    read "${flags[@]}" choice
    choice="${choice:-$default}"
    case "$choice" in
        1|T|TRUE|True|Y|YES|Yes|true|y|yes)
            x=1
            ;;
        0|F|FALSE|False|N|NO|No|false|n|no)
            x=0
            ;;
        *)
            koopa::stop "Invalid 'yes/no' choice."
            ;;
    esac
    koopa::print "$x"
    return 0
}
