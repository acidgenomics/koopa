#!/usr/bin/env bash

_koopa_clone() {
    # """
    # Clone files using rsync (with saner defaults).
    # @note Updated 2022-04-04.
    # """
    local -A dict
    local -a rsync_args
    _koopa_assert_has_args_eq "$#" 2
    _koopa_assert_has_no_flags "$@"
    dict['source_dir']="${1:?}"
    dict['target_dir']="${2:?}"
    _koopa_assert_is_dir "${dict['source_dir']}" "${dict['target_dir']}"
    dict['source_dir']="$( \
        _koopa_realpath "${dict['source_dir']}" \
        | _koopa_strip_trailing_slash \
    )"
    dict['target_dir']="$( \
        _koopa_realpath "${dict['target_dir']}" \
        | _koopa_strip_trailing_slash \
    )"
    _koopa_dl \
        'Source dir' "${dict['source_dir']}" \
        'Target dir' "${dict['target_dir']}"
    rsync_args=(
        '--archive'
        '--delete-before'
        "--source-dir=${dict['source_dir']}"
        "--target-dir=${dict['target_dir']}"
    )
    _koopa_rsync "${rsync_args[@]}"
    return 0
}
