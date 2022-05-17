#!/usr/bin/env bash

koopa_is_gitlab_ssh_enabled() {
    # """
    # Is SSH key enabled for GitLab access?
    # @note Updated 2020-06-30.
    # """
    koopa_assert_has_no_args "$#"
    __koopa_is_ssh_enabled 'git@gitlab.com' 'Welcome to GitLab'
}
