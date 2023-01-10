#!/usr/bin/env bash

koopa_fedora_dnf_delete_repo() {
    # """
    # Delete an enabled dnf repo.
    # @note Updated 2021-06-16.
    # """
    local file name
    koopa_assert_has_args "$#"
    for name in "$@"
    do
        file="/etc/yum.repos.d/${name}.repo"
        koopa_assert_is_file "$file"
        koopa_rm --sudo "$file"
    done
    return 0
}
