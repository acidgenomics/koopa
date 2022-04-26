#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install TeX packages.
    # @note Updated 2022-04-26.
    #
    # Including both curl and wget here is useful, to avoid SSH certificate
    # check timeouts and/or other issues.
    # """
    local app package packages
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'curl' 'gnupg' 'wget'
    declare -A app=(
        [sudo]="$(koopa_locate_sudo)"
        [tlmgr]="$(koopa_locate_tlmgr)"
    )
    "${app[sudo]}" "${app[tlmgr]}" update --self
    packages=(
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
    for package in "${packages[@]}"
    do
        koopa_alert "$package"
        "${app[sudo]}" "${app[tlmgr]}" install "$package"
    done
    return 0
}
