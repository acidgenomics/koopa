#!/usr/bin/env bash

koopa::install_tex_packages() { # {{{1
    # """
    # Install TeX packages.
    # @note Updated 2021-05-05.
    # """
    local name_fancy package packages
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed tlmgr
    koopa::assert_has_sudo
    name_fancy='TeX packages'
    koopa::install_start "$name_fancy"
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
    koopa::install_success "$name_fancy"
    return 0
}

koopa::update_tex() { # {{{1
    # """
    # Update TeX.
    # @note Updated 2021-05-05.
    # """
    local name_fancy
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed tlmgr
    koopa::assert_has_sudo
    name_fancy='TeX packages'
    koopa::update_start "$name_fancy"
    sudo tlmgr update --self
    sudo tlmgr update --list
    sudo tlmgr update --all
    koopa::update_success "$name_fancy"
    return 0
}
