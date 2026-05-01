#!/usr/bin/env bash

_koopa_get_version_arg() {
    # """
    # Return matching version argument for an input program.
    # @note Updated 2022-06-20.
    # """
    local arg name
    _koopa_assert_has_args_eq "$#" 1
    name="$(_koopa_basename "${1:?}")"
    case "$name" in
        'apptainer' | \
        'docker-credential-pass' | \
        'go' | \
        'openssl' | \
        'rstudio-server')
            arg='version'
            ;;
        'exiftool')
            arg='-ver'
            ;;
        'lua')
            arg='-v'
            ;;
        'openssh' | \
        'ssh' | \
        'tmux')
            arg='-V'
            ;;
        *)
            arg='--version'
            ;;
    esac
    _koopa_print "$arg"
    return 0
}
