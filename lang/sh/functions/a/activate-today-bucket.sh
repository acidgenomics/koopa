#!/bin/sh

_koopa_activate_today_bucket() {
    # """
    # Create a dated file today bucket.
    # @note Updated 2024-09-17.
    #
    # Also adds a '~/today' symlink for quick access.
    #
    # How to check if a symlink target matches a specific path:
    # https://stackoverflow.com/questions/19860345
    #
    # Useful link flags:
    # -f, --force
    #        remove existing destination files
    # -n, --no-dereference
    #        treat LINK_NAME as a normal file if it is a symbolic link to a
    #        directory
    # -s, --symbolic
    #        make symbolic links instead of hard links
    # """
    __kvar_bucket_dir="${KOOPA_BUCKET:-}"
    if [ -n "$__kvar_bucket_dir" ]
    then
        [ -d "$KOOPA_BUCKET" ] || return 1
        __kvar_today_link="${HOME:?}/today"
    elif [ -d "${HOME:?}/bucket" ]
    then
        __kvar_bucket_dir="${HOME:?}/bucket"
        __kvar_today_link="${HOME:?}/today"
    elif [ -d "${HOME:?}/Documents/bucket" ]
    then
        __kvar_bucket_dir="${HOME:?}/Documents/bucket"
        __kvar_today_link="${HOME:?}/Documents/today"
    else
        unset -v __kvar_bucket_dir
        return 0
    fi
    __kvar_today_subdirs="$(date '+%Y/%m/%d')"
    if _koopa_str_detect_posix \
        "$(_koopa_realpath "$__kvar_today_link")" \
        "$__kvar_today_subdirs"
    then
        unset -v \
            __kvar_bucket_dir \
            __kvar_today_link \
            __kvar_today_subdirs
        return 0
    fi
    _koopa_is_alias 'ln' && unalias 'ln'
    _koopa_is_alias 'mkdir' && unalias 'mkdir'
    mkdir -p \
        "${__kvar_bucket_dir}/${__kvar_today_subdirs}" \
        >/dev/null
    ln -fns \
        "${__kvar_bucket_dir}/${__kvar_today_subdirs}" \
        "$__kvar_today_link" \
        >/dev/null
    unset -v \
        __kvar_bucket_dir \
        __kvar_today_link \
        __kvar_today_subdirs
    return 0
}
