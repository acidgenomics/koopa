#!/usr/bin/env bash

_koopa_tmp_log_file() {
    # """
    # Create temporary log file.
    # @note Updated 2020-11-23.
    #
    # Used primarily for debugging installation scripts.
    #
    # Note that mktemp on macOS and BusyBox doesn't support '--suffix' flag.
    # Otherwise, we can use:
    # > _koopa_mktemp --suffix='.log'
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_tmp_file
    return 0
}
