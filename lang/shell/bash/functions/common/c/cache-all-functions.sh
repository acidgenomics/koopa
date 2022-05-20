#!/usr/bin/env bash

koopa_cache_all_functions() {
    # """
    # Cache all koopa functions.
    # @note Updated 2022-05-20.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [koopa_prefix]="$(koopa_koopa_prefix)"
    )
    dict[shell_prefix]="${dict[koopa_prefix]}/lang/shell"
    koopa_cache_functions \
        "${dict[shell_prefix]}/bash/functions/activate" \
        "${dict[shell_prefix]}/bash/functions/common" \
        "${dict[shell_prefix]}/bash/functions/os/linux/alpine" \
        "${dict[shell_prefix]}/bash/functions/os/linux/arch" \
        "${dict[shell_prefix]}/bash/functions/os/linux/common" \
        "${dict[shell_prefix]}/bash/functions/os/linux/debian" \
        "${dict[shell_prefix]}/bash/functions/os/linux/fedora" \
        "${dict[shell_prefix]}/bash/functions/os/linux/opensuse" \
        "${dict[shell_prefix]}/bash/functions/os/linux/rhel" \
        "${dict[shell_prefix]}/bash/functions/os/macos" \
        "${dict[shell_prefix]}/posix/functions"
    return 0
}
