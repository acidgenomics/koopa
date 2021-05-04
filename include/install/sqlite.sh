#!/usr/bin/env bash

install_sqlite() { # {{{1
    # """
    # Install SQLite.
    # @note Updated 2021-04-27.
    #
    # Use autoconf instead of amalgamation.
    #
    # The '--enable-static' flag is required, otherwise you'll hit a version
    # mismatch error:
    # > sqlite3 --version
    # ## SQLite header and source version mismatch
    # https://askubuntu.com/questions/443379
    # """
    local file file_version flags jobs name prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='sqlite'
    jobs="$(koopa::cpu_count)"
    case "$version" in
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
    # e.g. 3.32.3 to 3320300.
    file_version="$( \
        koopa::print "$version" \
        | sed -E 's/^([0-9]+)\.([0-9]+)\.([0-9]+)$/\1\20\300/'
    )"
    file="${name}-autoconf-${file_version}.tar.gz"
    url="https://www.sqlite.org/${year}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-autoconf-${file_version}"
    flags=(
        # Potential flags:
        # > '--disable-dynamic-extensions'
        # > '--disable-shared'
        "--prefix=${prefix}"
        '--enable-static'
    )
    ./configure "${flags[@]}"
    make --jobs="$jobs"
    make install
    koopa::alert_note 'Reinstall PROJ and GDAL, if built from source.'
    return 0
}

install_sqlite "$@"
