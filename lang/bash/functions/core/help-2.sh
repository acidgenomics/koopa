#!/usr/bin/env bash

_koopa_help_2() {
    # """
    # Resolve man file for current script, and call help.
    # @note Updated 2023-03-17.
    #
    # Currently used inside shared Bash header.
    # """
    local -A dict
    dict['script_file']="$(_koopa_realpath "$0")"
    dict['script_name']="$(_koopa_basename "${dict['script_file']}")"
    dict['man_prefix']="$( \
        _koopa_parent_dir --num=2 "${dict['script_file']}" \
    )"
    dict['man_file']="${dict['man_prefix']}/share/man/\
man1/${dict['script_name']}.1"
    _koopa_assert_is_file "${dict['man_file']}"
    _koopa_help "${dict['man_file']}"
}
