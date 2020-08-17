#!/usr/bin/env bash

koopa::install_tex_packages() { # {{{1
    local package packages
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed tlmgr
    koopa::h1 'Installing TeX packages recommended for RStudio.'
    sudo tlmgr update --self
    packages=(
        collection-fontsrecommended  # priority
        collection-latexrecommended  # priority
        bera  # beramono
        biblatex
        caption
        changepage
        csvsimple
        enumitem
        etoolbox
        fancyhdr
        footmisc
        framed
        geometry
        hyperref
        inconsolata
        logreq
        marginfix
        mathtools
        natbib
        nowidow
        parnotes
        parskip
        placeins
        preprint  # authblk
        sectsty
        soul
        titlesec
        titling
        units
        wasysym
        xstring
    )
    for package in "${packages[@]}"
    do
        sudo tlmgr install "$package"
    done
    return 0
}

koopa::update_tex() { # {{{1
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed tlmgr
    koopa::h1 'Updating TeX Live.'
    sudo tlmgr update --self
    sudo tlmgr update --list
    sudo tlmgr update --all
    return 0
}
