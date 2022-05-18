#!/usr/bin/env bash

koopa_debian_apt_delete_repo() {
    # """
    # Delete an apt repo file.
    # @note Updated 2022-05-18.
    # """
    local dict name
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    declare -A dict=(
        [prefix]="$(koopa_debian_apt_sources_prefix)"
    )
    for name in "$@"
    do
        local file
        file="${dict[prefix]}/koopa-${name}.list"
        koopa_assert_is_file "$file"
        koopa_rm --sudo "$file"
    done
    return 0
}
