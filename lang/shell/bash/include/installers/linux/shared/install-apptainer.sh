#!/usr/bin/env bash

main() {
    # """
    # Install Apptainer.
    # @note Updated 2022-06-14.
    #
    # @seealso
    # - https://github.com/apptainer/apptainer
    # - https://issueexplorer.com/issue/hpcng/singularity/6225
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'go' 'pkg-config'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [gopath]="$(koopa_init_dir 'go')"
        [name]='apptainer'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
        [version_file]='VERSION'
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/apptainer/${dict[name]}/archive/refs/\
tags/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    # This step is needed to avoid an error when not cloned from git repo.
    if [[ ! -f "${dict[version_file]}" ]]
    then
        koopa_print "${dict[version]}" > "${dict[version_file]}"
    fi
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--without-suid'
        '-P' 'release-stripped'
        '-v'
    )
    export GOPATH="${dict[gopath]}"
    ./mconfig "${conf_args[@]}"
    "${app[make]}" -C 'builddir'
    "${app[make]}" -C 'builddir' install
    koopa_chmod --recursive 'u+rw' "${dict[gopath]}"
    return 0
}
