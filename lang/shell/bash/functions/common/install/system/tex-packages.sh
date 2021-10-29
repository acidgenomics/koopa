#!/usr/bin/env bash

koopa::install_tex_packages() { # {{{1
    # """
    # Install TeX packages.
    # @note Updated 2021-10-29.
    # """
    local app name_fancy package packages
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [sudo]="$(koopa::locate_sudo)"
        [tlmgr]="$(koopa::locate_tlmgr)"
    )
    name_fancy='TeX packages'
    koopa::install_start "$name_fancy"
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
    koopa::install_success "$name_fancy"
    return 0
}

koopa::update_tex_packages() { # {{{1
    # """
    # Update TeX packages.
    # @note Updated 2021-10-29.
    # """
    local name_fancy
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [sudo]="$(koopa::locate_sudo)"
        [tlmgr]="$(koopa::locate_tlmgr)"
    )
    name_fancy='TeX packages'
    koopa::update_start "$name_fancy"
    "${app[sudo]}" "${app[tlmgr]}" update --self
    "${app[sudo]}" "${app[tlmgr]}" update --list
    "${app[sudo]}" "${app[tlmgr]}" update --all
    koopa::update_success "$name_fancy"
    return 0
}
