#!/usr/bin/env bash

koopa:::install_sqlite() { # {{{1
    # """
    # Install SQLite.
    # @note Updated 2022-01-06.
    #
    # Use autoconf instead of amalgamation.
    #
    # Year mappings for installers are here:
    # https://www.sqlite.org/chronology.html
    #
    # The '--enable-static' flag is required, otherwise you'll hit a version
    # mismatch error:
    # > sqlite3 --version
    # ## SQLite header and source version mismatch
    # https://askubuntu.com/questions/443379
    # """
    local app conf_args dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa::locate_make)"
        [sed]="$(koopa::locate_sed)"
    )
    declare -A dict=(
        [jobs]="$(koopa::cpu_count)"
        [name]='sqlite'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    case "${dict[version]}" in
        '3.37.2')
            dict[year]='2022'
            ;;
        '3.37.1' | \
        '3.37.0' | \
        '3.36.'* | \
        '3.35.'* | \
        '3.34.1')
            dict[year]='2021'
            ;;
        '3.34.0' | \
        '3.33.'*)
            dict[year]='2020'
            ;;
        '3.32.'*)
            dict[year]='2020'
            ;;
        *)
            koopa::stop "Unsupported version: '${dict[version]}'."
            ;;
    esac
    # e.g. '3.32.3' to '3320300'.
    dict[file_version]="$( \
        koopa::print "${dict[version]}" \
        | "${app[sed]}" -E 's/^([0-9]+)\.([0-9]+)\.([0-9]+)$/\1\20\300/'
    )"
    dict[file]="${dict[name]}-autoconf-${dict[file_version]}.tar.gz"
    dict[url]="https://www.sqlite.org/${dict[year]}/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-autoconf-${dict[file_version]}"
    conf_args=(
        # > '--disable-dynamic-extensions'
        # > '--disable-shared'
        "--prefix=${dict[prefix]}"
        '--enable-static'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    koopa::alert_note 'Reinstall PROJ and GDAL, if built from source.'
    return 0
}
