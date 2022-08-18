#!/usr/bin/env bash

main() {
    local dict
    koopa_assert_has_no_args "$#"
    koopa_is_admin || return 0
    declare -A dict=(
        [default_java]='/usr/lib/jvm/default-java'
    )
    if [[ -d "${dict[default_java]}" ]]
    then
        koopa_linux_java_update_alternatives "${dict[default_java]}"
    fi
    return 0
}
