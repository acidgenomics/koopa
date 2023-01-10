#!/bin/sh

koopa_activate_completion() {
    # """
    # Activate completion (with TAB key).
    # @note Updated 2021-05-06.
    # """
    local file koopa_prefix shell
    shell="$(koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    koopa_prefix="$(koopa_koopa_prefix)"
    for file in "${koopa_prefix}/etc/completion/"*'.sh'
    do
        # shellcheck source=/dev/null
        [ -f "$file" ] && . "$file"
    done
    return 0
}
