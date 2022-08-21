#!/usr/bin/env bash

main() {
    # """
    # Install Spacemacs.
    # @note Updated 2022-07-14.
    #
    # Note that master branch is ancient and way behind current codebase.
    # Switching to more recent code on develop branch.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'chemacs'
    declare -A dict=(
        [branch]='develop'
        [prefix]="${INSTALL_PREFIX:?}"
        [url]='https://github.com/syl20bnr/spacemacs.git'
    )
    koopa_git_clone \
        --branch="${dict['branch']}" \
        --prefix="${dict['prefix']}" \
        --url="${dict['url']}"
    return 0
}
