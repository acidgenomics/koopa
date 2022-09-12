#!/usr/bin/env bash

# NOTE Safe to ignore this warning/error:
# fatal: not a git repository (or any of the parent directories): .git

main() {
    # """
    # Install fzf.
    # @note Updated 2022-06-14.
    # @seealso
    # - https://github.com/junegunn/fzf/blob/master/BUILD.md
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'go'
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['gopath']="$(koopa_init_dir 'go')"
        ['jobs']="$(koopa_cpu_count)"
        ['name']='fzf'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['version']}.tar.gz"
    dict['url']="https://github.com/junegunn/${dict['name']}/archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    export FZF_REVISION='tarball'
    export FZF_VERSION="${dict['version']}"
    export GOPATH="${dict['gopath']}"
    koopa_print_env
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    # This will copy fzf binary from 'target/' to 'bin/'.
    "${app['make']}" install
    # > ./install --help
    ./install --bin --no-update-rc
    koopa_cp \
        --target-directory="${dict['prefix']}" \
        'bin' 'doc' 'man' 'plugin' 'shell'
    koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}
