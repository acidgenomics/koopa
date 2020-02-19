#!/bin/sh
# shellcheck disable=SC2039

# FIXME Add '--recursive' flag support.
# FIXME Add '--user' flag support.
_koopa_set_permissions() {  # {{{1
    # """
    # Set permissions on target prefix(es).
    # @note Updated 2020-02-19.
    # """

    local recursive
    recursive=0

    local user
    user=0

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
            --)
                shift 1
                break
                ;;
            --*|-*)
                _koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    set -- "${pos[@]}"

    # Error if the user hasn't requested any files.
    [ "$#" -gt 0 ] || return 1

    # FIXME Put these steps into a for loop.



    # chmod  {{{2
    # --------------------------------------------------

    _koopa_chmod \
        --recursive \
        "$(_koopa_chmod_flags)" \
        "$@"

    # chown  {{2
    # --------------------------------------------------

    local group
    group="$(_koopa_group)"

    case "$user" in
        0)
            user="$(_koopa_user)"
            ;;
        1)
            user="${USER:?}" \
            ;;
    esac

    # FIXME Need to add recursive support here.
    _koopa_chown \
        --no-dereference \
        --recursive \
        "${user}:${group}" \
        "$@"

    return 0
}

