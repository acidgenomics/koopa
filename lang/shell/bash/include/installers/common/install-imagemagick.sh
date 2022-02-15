#!/usr/bin/env bash

koopa:::install_imagemagick() { # {{{1
    # """
    # Install ImageMagick.
    # @note Updated 2022-02-15.
    #
    # @seealso
    # - https://imagemagick.org/script/install-source.php
    # - https://imagemagick.org/script/advanced-linux-installation.php
    # - https://download.imagemagick.org/ImageMagick/download/releases/
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[mmp_ver]="$(koopa::major_minor_patch_version "${dict[version]}")"
    dict[file]="ImageMagick-${dict[version]}.tar.xz"
    dict[url]="https://www.imagemagick.org/download/releases/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "ImageMagick-${dict[mmp_ver]}"
    ./configure \
        --prefix="${dict[prefix]}" \
        --with-modules
    "${app[make]}"
    "${app[make]}" install
    return 0
}
