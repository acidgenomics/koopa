#!/usr/bin/env bash

koopa_macos_disable_privileged_helper_tool() {
    # """
    # Disable a privileged helper tool.
    # @note Updated 2023-04-06.
    # """
    local bn
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    for bn in "$@"
    do
        local -A dict
        dict['enabled_file']="/Library/PrivilegedHelperTools/${bn}"
        dict['disabled_file']="$(koopa_dirname "${dict['enabled_file']}")/\
disabled/$(koopa_basename "${dict['enabled_file']}")"
        koopa_assert_is_file "${dict['enabled_file']}"
        koopa_assert_is_not_file "${dict['disabled_file']}"
        koopa_alert "Disabling '${dict['disabled_file']}'."
        koopa_mv --sudo "${dict['enabled_file']}" "${dict['disabled_file']}"
    done
    return 0
}
