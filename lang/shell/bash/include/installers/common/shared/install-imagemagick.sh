#!/usr/bin/env bash

main() {
    # """
    # Install ImageMagick.
    # @note Updated 2022-07-20.
    #
    # @seealso
    # - https://imagemagick.org/script/install-source.php
    # - https://imagemagick.org/script/advanced-linux-installation.php
    # - https://download.imagemagick.org/ImageMagick/download/releases/
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'libtool'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    [[ -x "${app[make]}" ]] || return 1
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[mmp_ver]="$(koopa_major_minor_patch_version "${dict[version]}")"
    dict[file]="ImageMagick-${dict[version]}.tar.xz"
    dict[url]="https://imagemagick.org/archive/releases/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "ImageMagick-${dict[mmp_ver]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--with-modules'
    )
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app[make]}"
    "${app[make]}" install
    return 0
}
