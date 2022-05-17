#!/usr/bin/env bash

koopa_sys_ln() {
    # """
    # Create a symlink quietly.
    # @note Updated 2022-04-26.
    #
    # Don't need to set 'g+rw' for symbolic link here.
    # Symlink permissions are ignored on most systems, including Linux.
    #
    # On macOS, you can override using BSD ln:
    # > /bin/ln -h g+rw <file>
    # """
    local dict
    koopa_assert_has_args_eq "$#" 2
    declare -A dict=(
        [source]="${1:?}"
        [target]="${2:?}"
    )
    # This helps avoid 'locate_ln' issue when reinstalling coreutils.
    koopa_rm "${dict[target]}"
    koopa_ln "${dict[source]}" "${dict[target]}"
    if koopa_is_macos
    then
        koopa_sys_set_permissions --no-dereference "${dict[target]}"
    fi
    return 0
}
