#!/usr/bin/env bash

koopa:::install_tex_packages() { # {{{1
    # """
    # Install TeX packages.
    # @note Updated 2021-11-13.
    # """
    local app package packages
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [sudo]="$(koopa::locate_sudo)"
        [tlmgr]="$(koopa::locate_tlmgr)"
    )
    "${app[sudo]}" "${app[tlmgr]}" update --self
    packages=(
        # Priority ----
        'collection-fontsrecommended'
        'collection-latexrecommended'
        # Alphabetical ---
        'bera'  # beramono
        'biblatex'
        'caption'
        'changepage'
        'csvsimple'
        'enumitem'
        'etoolbox'
        'fancyhdr'
        'footmisc'
        'framed'
        'geometry'
        'hyperref'
        'inconsolata'
        'logreq'
        'marginfix'
        'mathtools'
        'natbib'
        'nowidow'
        'parnotes'
        'parskip'
        'placeins'
        'preprint'  # authblk
        'sectsty'
        'soul'
        'titlesec'
        'titling'
        'units'
        'wasysym'
        'xstring'
    )
    for package in "${packages[@]}"
    do
        "${app[sudo]}" "${app[tlmgr]}" install "$package"
    done
    return 0
}
