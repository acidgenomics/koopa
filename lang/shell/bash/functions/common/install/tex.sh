#!/usr/bin/env bash

koopa::install_tex_packages() { # {{{1
    # """
    # Install TeX packages.
    # @note Updated 2020-11-25.
    # """
    local package packages
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed tlmgr
    koopa::assert_has_sudo
    koopa::h1 'Installing TeX packages recommended for RStudio.'
    sudo tlmgr update --self
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
        sudo tlmgr install "$package"
    done
    return 0
}

koopa::update_tex() { # {{{1
    # """
    # Update TeX.
    # @note Updated 2020-11-18.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed tlmgr
    koopa::assert_has_sudo
    koopa::h1 'Updating TeX Live.'
    sudo tlmgr update --self
    sudo tlmgr update --list
    sudo tlmgr update --all
    return 0
}
