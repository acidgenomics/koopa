#!/usr/bin/env bash

_koopa_is_github_ssh_enabled() {
    # """
    # Is SSH key enabled for GitHub access?
    # @note Updated 2020-06-30.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_is_ssh_enabled 'git@github.com' 'successfully authenticated'
}
