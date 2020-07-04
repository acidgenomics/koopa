#!/usr/bin/env bash

koopa::set_permissions() { # {{{1
    # """
    # Set permissions on target prefix(es).
    # @note Updated 2020-06-30.
    #
    # @param --recursive
    #   Change permissions recursively.
    # @param --user
    #   Change ownership to current user, rather than koopa default, which is
    #   root for shared installs.
    # """
    koopa::assert_has_args "$#"
    local recursive
    recursive=0
    local user
    user=0
    local verbose
    verbose=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --recursive)
                recursive=1
                shift 1
                ;;
            --user)
                user=1
                shift 1
                ;;
            --verbose)
                verbose=1
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    # chmod flags.
    local chmod_flags
    readarray -t chmod_flags <<< "$(koopa::chmod_flags)"
    if [[ "$recursive" -eq 1 ]]
    then
        # Note that '-R' instead of '--recursive' has better cross-platform
        # support on macOS and BusyBox.
        chmod_flags+=("-R")
    fi
    if [[ "$verbose" -eq 1 ]]
    then
        # Note that '-v' instead of '--verbose' has better cross-platform
        # support on macOS and BusyBox.
        chmod_flags+=("-v")
    fi
    # chown flags.
    local chown_flags
    # Note that '-h' instead of '--no-dereference' has better cross-platform
    # support on macOS and BusyBox.
    chown_flags=("-h")
    if [[ "$recursive" -eq 1 ]]
    then
        # Note that '-R' instead of '--recursive' has better cross-platform
        # support on macOS and BusyBox.
        chown_flags+=("-R")
    fi
    if [[ "$verbose" -eq 1 ]]
    then
        # Note that '-v' instead of '--verbose' has better cross-platform
        # support on macOS and BusyBox.
        chown_flags+=("-v")
    fi
    local group
    group="$(koopa::group)"
    local who
    case "$user" in
        0)
            who="$(koopa::user)"
            ;;
        1)
            who="${USER:?}" \
            ;;
    esac
    chown_flags+=("${who}:${group}")
    # Loop across input and set permissions.
    for arg in "$@"
    do
        # Ensure we resolve symlinks here.
        arg="$(realpath "$arg")"
        koopa::chmod "${chmod_flags[@]}" "$arg"
        koopa::chown "${chown_flags[@]}" "$arg"
    done
    return 0
}
