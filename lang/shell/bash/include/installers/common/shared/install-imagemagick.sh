#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install ImageMagick.
    # @note Updated 2022-04-11.
    #
    # @seealso
    # - https://imagemagick.org/script/install-source.php
    # - https://imagemagick.org/script/advanced-linux-installation.php
    # - https://download.imagemagick.org/ImageMagick/download/releases/
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'libtool'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[mmp_ver]="$(koopa_major_minor_patch_version "${dict[version]}")"
    dict[file]="ImageMagick-${dict[version]}.tar.xz"
    dict[url]="https://www.imagemagick.org/download/releases/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "ImageMagick-${dict[mmp_ver]}"
    ./configure \
        --prefix="${dict[prefix]}" \
        --with-modules
    "${app[make]}"
    "${app[make]}" install
    return 0
}
