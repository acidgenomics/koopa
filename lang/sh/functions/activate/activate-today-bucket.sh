#!/bin/sh

_koopa_activate_today_bucket() {
    # """
    # Create a dated file today bucket.
    # @note Updated 2026-08-24.
    #
    # Maintains dated 'today' symlinks at both '~/today' and
    # '~/Documents/today'. These are two independent dated links (not an
    # alias pair), each repointed at '<bucket>/YYYY/MM/DD' on its own, so
    # either path stays current regardless of which bucket directory koopa
    # resolves.
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
    _koopa_is_interactive || return 0
    __kvar_bucket_dir="${KOOPA_BUCKET:-}"
    if [ -n "$__kvar_bucket_dir" ]
    then
        [ -d "$KOOPA_BUCKET" ] || return 0
    elif [ -d "${HOME:?}/bucket" ]
    then
        __kvar_bucket_dir="${HOME:?}/bucket"
    elif [ -d "${HOME:?}/Documents/bucket" ]
    then
        __kvar_bucket_dir="${HOME:?}/Documents/bucket"
    else
        unset -v __kvar_bucket_dir
        return 0
    fi
    # Resolve to the real directory, so the dated links never point through
    # a symlink alias (e.g. '~/bucket' -> 'Documents/bucket').
    __kvar_bucket_dir="$(_koopa_realpath "$__kvar_bucket_dir")"
    __kvar_today_subdirs="$(date '+%Y/%m/%d')"
    mkdir -p \
        "${__kvar_bucket_dir}/${__kvar_today_subdirs}" \
        >/dev/null
    for __kvar_today_link in \
        "${HOME:?}/today" \
        "${HOME:?}/Documents/today"
    do
        if [ -d "$__kvar_today_link" ] && \
            _koopa_str_detect_posix \
                "$(_koopa_realpath "$__kvar_today_link")" \
                "$__kvar_today_subdirs"
        then
            continue
        fi
        ln -fns \
            "${__kvar_bucket_dir}/${__kvar_today_subdirs}" \
            "$__kvar_today_link" \
            >/dev/null
    done
    unset -v \
        __kvar_bucket_dir \
        __kvar_today_link \
        __kvar_today_subdirs
    return 0
}
