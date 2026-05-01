#!/usr/bin/env bash

_koopa_macos_enable_privileged_helper_tool() {
    # """
    # Enable a privileged helper tool.
    # @note Updated 2023-04-06.
    # """
    local bn
    _koopa_assert_has_args "$#"
    _koopa_assert_is_admin
    for bn in "$@"
    do
        local -A dict
        dict['enabled_file']="/Library/PrivilegedHelperTools/${bn}"
        dict['disabled_file']="$(_koopa_dirname "${dict['enabled_file']}")/\
disabled/$(_koopa_basename "${dict['enabled_file']}")"
        _koopa_assert_is_not_file "${dict['enabled_file']}"
        _koopa_assert_is_file "${dict['disabled_file']}"
        _koopa_alert "Enabling '${dict['disabled_file']}'."
        _koopa_mv --sudo "${dict['disabled_file']}" "${dict['enabled_file']}"
    done
    return 0
}
