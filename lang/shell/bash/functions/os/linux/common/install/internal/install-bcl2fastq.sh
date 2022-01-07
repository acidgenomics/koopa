#!/usr/bin/env bash

# NOTE Currently failing to install on Ubuntu 20:
# ## include could not find load file:
# ## CMakeFindDependencyMacro
# ## Unknown CMake command "find_dependency".

koopa:::linux_install_bcl2fastq() { # {{{1
    # """
    # Install bcl2fastq from source.
    # @note Updated 2022-01-07.
    #
    # This uses CMake to install.
    # ARM is not yet supported for this.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [arch]="$(koopa::arch)"
        [installers_url]="$(koopa::koopa_installers_url)"
        [jobs]="$(koopa::cpu_count)"
        [name]='bcl2fastq'
        [platform]='linux-gnu'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[maj_ver]="$(koopa::major_version "${dict[version]}")"
    # e.g. '2.20.0.422' to '2-20-0'.
    dict[version2]="$(koopa::sub '\.[0-9]+$' '' "${dict[version]}")"
    dict[version2]="$(koopa::kebab_case_simple "${dict[version2]}")"
    dict[file]="${dict[name]}${dict[maj_ver]}-v${dict[version2]}-tar.zip"
    dict[url]="${dict[installers_url]}/${dict[name]}/source/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::extract "${dict[name]}${dict[maj_ver]}-v${dict[version]}-\
Source.tar.gz"
    koopa::cd "${dict[name]}"
    koopa::mkdir "${dict[name]}-build"
    koopa::cd "${dict[name]}-build"
    # Fix for missing '/usr/include/x86_64-linux-gnu/sys/stat.h'.
    export C_INCLUDE_PATH="/usr/include/${dict[arch]}-${dict[platform]}"
    ../src/configure --prefix="${dict[prefix]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    # For some reason bcl2fastq creates an empty test directory.
    koopa::rm "${dict[prefix]}/bin/test"
    return 0
}
