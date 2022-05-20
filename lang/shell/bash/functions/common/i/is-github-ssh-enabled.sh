#!/usr/bin/env bash

koopa_is_github_ssh_enabled() {
    # """
    # Is SSH key enabled for GitHub access?
    # @note Updated 2020-06-30.
    # """
    koopa_assert_has_no_args "$#"
    __koopa_is_ssh_enabled 'git@github.com' 'successfully authenticated'
}
