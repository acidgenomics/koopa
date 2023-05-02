#!/usr/bin/env bash

main() {
    # """
    # Install TeX packages.
    # @note Updated 2023-05-01.
    #
    # Including both curl and wget here is useful, to avoid SSH certificate
    # check timeouts and/or other issues.
    # """
    local -A app
    local -a pkgs
    local pkg
    koopa_activate_app --build-only 'curl' 'gnupg' 'wget'
    app['tlmgr']="$(koopa_locate_tlmgr)"
    koopa_assert_is_executable "${app[@]}"
    koopa_sudo "${app['tlmgr']}" update --self
    pkgs=(
        # Priority ----
        'collection-fontsrecommended'
        'collection-latexrecommended'
        # Alphabetical ---
        'bera' # beramono
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
        'preprint' # authblk
        'sectsty'
        'soul'
        'titlesec'
        'titling'
        'units'
        'wasysym'
        'xstring'
    )
    for pkg in "${pkgs[@]}"
    do
        koopa_alert "$pkg"
        koopa_sudo "${app['tlmgr']}" install "$pkg"
    done
    return 0
}
