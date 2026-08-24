#!/usr/bin/env bash

_koopa_activate_today_bucket() {
    # """
    # Maintain dated 'today' symlinks.
    # @note Updated 2026-08-24.
    #
    # Maintains dated 'today' symlinks at both '~/today' and
    # '~/Documents/today'. These are two independent dated links (not an
    # alias pair), each repointed at '<bucket>/YYYY/MM/DD' on its own, so
    # either path stays current regardless of which bucket directory koopa
    # resolves.
    # """
    _koopa_is_interactive || return 0
    local bucket_dir
    bucket_dir="${KOOPA_BUCKET:-}"
    if [[ -n "$bucket_dir" ]]
    then
        [[ -d "$KOOPA_BUCKET" ]] || return 0
    elif [[ -d "${HOME:?}/bucket" ]]
    then
        bucket_dir="${HOME:?}/bucket"
    elif [[ -d "${HOME:?}/Documents/bucket" ]]
    then
        bucket_dir="${HOME:?}/Documents/bucket"
    else
        return 0
    fi
    # Resolve to the real directory, so the dated links never point through
    # a symlink alias (e.g. '~/bucket' -> 'Documents/bucket').
    bucket_dir="$(_koopa_realpath "$bucket_dir")"
    local today_subdirs
    today_subdirs="$(date '+%Y/%m/%d')"
    mkdir -p \
        "${bucket_dir}/${today_subdirs}" \
        >/dev/null
    local today_link
    for today_link in \
        "${HOME:?}/today" \
        "${HOME:?}/Documents/today"
    do
        if [[ -d "$today_link" ]] && \
            _koopa_str_detect_posix \
                "$(_koopa_realpath "$today_link")" \
                "$today_subdirs"
        then
            continue
        fi
        ln -fns \
            "${bucket_dir}/${today_subdirs}" \
            "$today_link" \
            >/dev/null
    done
    return 0
}
