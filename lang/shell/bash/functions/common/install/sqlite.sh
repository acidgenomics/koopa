#!/usr/bin/env bash

koopa::install_sqlite() { # {{{1
    koopa::install_app \
        --name='sqlite' \
        --name-fancy='SQLite' \
        "$@"
}

koopa:::install_sqlite() { # {{{1
    # """
    # Install SQLite.
    # @note Updated 2021-05-06.
    #
    # Use autoconf instead of amalgamation.
    #
    # The '--enable-static' flag is required, otherwise you'll hit a version
    # mismatch error:
    # > sqlite3 --version
    # ## SQLite header and source version mismatch
    # https://askubuntu.com/questions/443379
    # """
    local conf_args file file_version jobs name prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='sqlite'
    jobs="$(koopa::cpu_count)"
    case "$version" in
        3.35.* | \
        3.34.1)
            year='2021'
            ;;
        3.34.0 | \
        3.33.*)
            year='2020'
            ;;
        3.32.*)
            year='2020'
            ;;
        *)
            koopa::stop "Unsupported version: ${version}."
            ;;
    esac
    # e.g. '3.32.3' to '3320300'.
    file_version="$( \
        koopa::print "$version" \
        | sed -E 's/^([0-9]+)\.([0-9]+)\.([0-9]+)$/\1\20\300/'
    )"
    file="${name}-autoconf-${file_version}.tar.gz"
    url="https://www.sqlite.org/${year}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-autoconf-${file_version}"
    conf_args=(
        # > '--disable-dynamic-extensions'
        # > '--disable-shared'
        "--prefix=${prefix}"
        '--enable-static'
    )
    ./configure "${conf_args[@]}"
    make --jobs="$jobs"
    make install
    koopa::alert_note 'Reinstall PROJ and GDAL, if built from source.'
    return 0
}
