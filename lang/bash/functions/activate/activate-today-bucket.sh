#!/usr/bin/env bash

_koopa_activate_today_bucket() {
    local bucket_dir
    bucket_dir="${KOOPA_BUCKET:-}"
    local today_link
    if [[ -n "$bucket_dir" ]]
    then
        [[ -d "$KOOPA_BUCKET" ]] || return 1
        today_link="${HOME:?}/today"
    elif [[ -d "${HOME:?}/bucket" ]]
    then
        bucket_dir="${HOME:?}/bucket"
        today_link="${HOME:?}/today"
    elif [[ -d "${HOME:?}/Documents/bucket" ]]
    then
        bucket_dir="${HOME:?}/Documents/bucket"
        today_link="${HOME:?}/Documents/today"
    else
        return 0
    fi
    local today_subdirs
    today_subdirs="$(date '+%Y/%m/%d')"
    if [[ -d "$today_link" ]] && \
        _koopa_str_detect_posix \
            "$(_koopa_realpath "$today_link")" \
            "$today_subdirs"
    then
        return 0
    fi
    mkdir -p \
        "${bucket_dir}/${today_subdirs}" \
        >/dev/null
    ln -fns \
        "${bucket_dir}/${today_subdirs}" \
        "$today_link" \
        >/dev/null
    return 0
}
