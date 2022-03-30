#!/usr/bin/env bash

# These functions only support current version lookup.

koopa_armadillo_version() { # {{{1
    # """
    # Armadillo: C++ library for linear algebra & scientific computing.
    # @note Updated 2021-03-01.
    # """
    koopa_assert_has_no_args "$#"
    koopa_get_version_from_pkg_config 'armadillo'
}

koopa_boost_version() { # {{{1
    # """
    # Boost (libboost) version.
    # @note Updated 2022-02-25.
    #
    # Extract the Boost library version using GCC preprocessing. This approach
    # is nice because it doesn't hardcode to a specific file path.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3708706/
    # - https://stackoverflow.com/questions/4518584/
    # """
    local app dict gcc_args
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [bc]="$(koopa_locate_bc)"
        [gcc]="$(koopa_locate_gcc)"
    )
    declare -A dict
    gcc_args=()
    if koopa_is_macos
    then
        dict[brew_prefix]="$(koopa_homebrew_prefix)"
        gcc_args+=("-I${dict[brew_prefix]}/opt/boost/include")
    fi
    gcc_args+=(
        '-x' 'c++'
        '-E' '-'
    )
    dict[version]="$( \
        koopa_print '#include <boost/version.hpp>\nBOOST_VERSION' \
        | "${app[gcc]}" "${gcc_args[@]}" \
        | koopa_grep --pattern='^[0-9]+$' --regex \
    )"
    [[ -n "${dict[version]}" ]] || return 1
    # Convert '107500' to '1.75.0', for example.
    dict[major]="$(koopa_print "${dict[version]} / 100000" | "${app[bc]}")"
    dict[minor]="$(koopa_print "${dict[version]} / 100 % 1000" | "${app[bc]}")"
    dict[patch]="$(koopa_print "${dict[version]} % 100" | "${app[bc]}")"
    koopa_print "${dict[major]}.${dict[minor]}.${dict[patch]}"
    return 0
}

koopa_cairo_version() { # {{{1
    # """
    # Cairo (libcairo) version.
    # @note Updated 2021-03-01.
    # """
    koopa_assert_has_no_args "$#"
    koopa_get_version_from_pkg_config 'cairo'
}

koopa_current_bcbio_nextgen_version() { # {{{1
    # """
    # Get the latest bcbio-nextgen stable release version.
    # @note Updated 2022-02-25.
    #
    # This approach checks for latest stable release available via bioconda.
    #
    # @examples
    # > koopa_current_bcbio_nextgen_version
    # # 1.2.9
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
    )
    str="$( \
        koopa_parse_url "https://raw.githubusercontent.com/bcbio/\
bcbio-nextgen/master/requirements-conda.txt" \
            | koopa_grep --pattern='bcbio-nextgen=' \
            | "${app[cut]}" --delimiter='=' --fields='2' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_current_bioconductor_version() { # {{{1
    # """
    # Current Bioconductor version.
    # @note Updated 2022-02-25.
    #
    # @examples
    # > koopa_current_bioconductor_version
    # # 3.14
    # """
    local str
    koopa_assert_has_no_args "$#"
    str="$(koopa_parse_url 'https://bioconductor.org/bioc-version')"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_current_ensembl_version() { # {{{1
    # """
    # Current Ensembl version.
    # @note Updated 2022-02-25.
    #
    # @examples
    # > koopa_current_ensembl_version
    # # 105
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [sed]="$(koopa_locate_sed)"
    )
    str="$( \
        koopa_parse_url 'ftp://ftp.ensembl.org/pub/current_README' \
        | "${app[sed]}" --quiet '3p' \
        | "${app[cut]}" --delimiter=' ' --fields='3' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_current_flybase_version() { # {{{1
    # """
    # Current FlyBase version.
    # @note Updated 2022-02-25.
    #
    # @examples
    # > koopa_current_flybase_version
    # # FB2022_01
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
        [tail]="$(koopa_locate_tail)"
    )
    str="$( \
        koopa_parse_url --list-only "ftp://ftp.flybase.net/releases/" \
        | koopa_grep --pattern='^FB[0-9]{4}_[0-9]{2}$' --regex \
        | "${app[tail]}" --lines=1 \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_current_gencode_version() { # {{{1
    # """
    # Current GENCODE version.
    # @note Updated 2022-02-25.
    #
    # @examples
    # > koopa_current_gencode_version
    # # 39
    # """
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [curl]="$(koopa_locate_curl)"
        [cut]="$(koopa_locate_cut)"
        [grep]="$(koopa_locate_grep)"
        [head]="$(koopa_locate_head)"
    )
    declare -A dict=(
        [organism]="${1:-}"
    )
    [[ -z "${dict[organism]}" ]] && dict[organism]='Homo sapiens'
    case "${dict[organism]}" in
        'Homo sapiens' | \
        'human')
            dict[short_name]='human'
            dict[pattern]='Release [0-9]+'
            ;;
        'Mus musculus' | \
        'mouse')
            dict[short_name]='mouse'
            dict[pattern]='Release M[0-9]+'
            ;;
        *)
            koopa_stop "Unsupported organism: '${dict[organism]}'."
            ;;
    esac
    dict[base_url]='https://www.gencodegenes.org'
    dict[url]="${dict[base_url]}/${dict[short_name]}/"
    dict[str]="$( \
        koopa_parse_url "${dict[url]}" \
        | koopa_grep \
            --only-matching \
            --pattern="${dict[pattern]}" \
            --regex \
        | "${app[head]}" --lines=1 \
        | "${app[cut]}" --delimiter=' ' --fields='2' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
    return 0
}

koopa_current_refseq_version() { # {{{1
    # """
    # Current RefSeq version.
    # @note Updated 2022-02-25.
    #
    # @examples
    # > koopa_current_refseq_version
    # # 210
    # """
    local str url
    koopa_assert_has_no_args "$#"
    url='ftp://ftp.ncbi.nlm.nih.gov/refseq/release/RELEASE_NUMBER'
    str="$(koopa_parse_url "$url")"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_current_wormbase_version() { # {{{1
    # """
    # Current WormBase version.
    # @note Updated 2022-02-25.
    #
    # @examples
    # > koopa_current_wormbase_version
    # # WS283
    # """
    local app str url
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
    )
    url="ftp://ftp.wormbase.org/pub/wormbase/\
releases/current-production-release"
    str="$( \
        koopa_parse_url --list-only "${url}/" \
            | koopa_grep \
                --only-matching \
                --pattern='letter.WS[0-9]+' \
                --regex \
            | "${app[cut]}" --delimiter='.' --fields='2' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_eigen_version() { # {{{1
    # """
    # Eigen (libeigen) version.
    # @note Updated 2021-03-01.
    # """
    koopa_assert_has_no_args "$#"
    koopa_get_version_from_pkg_config 'eigen3'
}

# > koopa_gtop_version() { # {{{1
# >     # """
# >     # gtop (Node package) version.
# >     # @note Updated 2022-03-15.
# >     # """
# >     koopa_assert_has_no_args "$#"
# >     koopa_node_package_version 'gtop'
# > }

koopa_harfbuzz_version() { # {{{1
    # """
    # HarfBuzz (libharfbuzz) version.
    # @note Updated 2021-03-01.
    # """
    koopa_assert_has_no_args "$#"
    koopa_get_version_from_pkg_config 'harfbuzz'
}

koopa_hdf5_version() { # {{{1
    # """
    # HDF5 version.
    # @note Updated 2022-02-27.
    #
    # Debian: 'dpkg -s libhdf5-dev'
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [h5cc]="$(koopa_locate_h5cc)"
        [sed]="$(koopa_locate_sed)"
    )
    str="$( \
        "${app[h5cc]}" -showconfig \
            | koopa_grep --pattern='HDF5 Version:' \
            | "${app[sed]}" --regexp-extended 's/^(.+): //' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_icu4c_version() { # {{{1
    # """
    # ICU version.
    # C/C++ and Java libraries for Unicode and globalization.
    # @note Updated 2021-09-15.
    # """
    koopa_assert_has_no_args "$#"
    koopa_get_version_from_pkg_config 'icu-uc'
}

koopa_imagemagick_version() { # {{{1
    # """
    # ImageMagick version.
    # @note Updated 2022-02-23.
    #
    # Other approach, that doesn't keep track of patch version:
    # > koopa_get_version_from_pkg_config 'ImageMagick'
    # """
    local app str
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [magick_core_config]="$(koopa_locate_magick_core_config)"
    )
    koopa_assert_has_no_args "$#"
    str="$( \
        "${app[magick_core_config]}" --version \
            | "${app[cut]}" --delimiter=' ' --fields=1 \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_koopa_version() { # {{{1
    # """
    # Koopa version.
    # @note Updated 2020-06-29.
    # """
    koopa_assert_has_no_args "$#"
    koopa_variable 'koopa-version'
    return 0
}

koopa_lmod_version() { # {{{1
    # """
    # Lmod version.
    # @note Updated 2022-02-23.
    # """
    local str
    koopa_assert_has_no_args "$#"
    str="${LMOD_VERSION:-}"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_npm_version() { # {{{1
    # """
    # Node package manager (NPM) version.
    # @note Updated 2022-03-21.
    # """
    koopa_assert_has_no_args "$#"
    koopa_node_package_version 'npm'
}

koopa_oracle_instantclient_version() { # {{{1
    # """
    # Oracle InstantClient version.
    # @note Updated 2022-02-27.
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [sqlplus]="$(koopa_locate_sqlplus)"
    )
    str="$( \
        "${app[sqlplus]}" -v \
            | koopa_grep --pattern='^Version' --regex \
            | koopa_extract_version \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_os_version() { # {{{1
    # """
    # Operating system version.
    # @note Updated 2022-02-27.
    #
    # Keep in mind that 'uname' returns Darwin kernel version for macOS.
    # """
    local str
    koopa_assert_has_no_args "$#"
    if koopa_is_linux
    then
        str="$(koopa_linux_os_version)"
    elif koopa_is_macos
    then
        str="$(koopa_macos_os_version)"
    fi
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_perl_file_rename_version() { # {{{1
    # """
    # Perl 'File::Rename' module version.
    # @note Updated 2022-03-18.
    # """
    koopa_assert_has_no_args "$#"
    koopa_perl_package_version 'File::Rename'
}

koopa_pip_version() { # {{{1
    # """
    # Python pip version.
    # @note Updated 2022-03-18.
    # """
    koopa_assert_has_no_args "$#"
    koopa_python_package_version 'pip'
}

# > koopa_prettier_version() { # {{{1
# >     # """
# >     # Prettier (Node package) version.
# >     # @note Updated 2022-03-15.
# >     # """
# >     koopa_assert_has_no_args "$#"
# >     koopa_node_package_version 'prettier'
# > }

koopa_xcode_clt_version() { # {{{1
    # """
    # Xcode CLT version.
    # @note Updated 2022-02-27.
    #
    # @seealso
    # - https://apple.stackexchange.com/questions/180957
    # - pkgutil --pkgs=com.apple.pkg.Xcode
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_is_xcode_clt_installed || return 1
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [pkgutil]="$(koopa_macos_locate_pkgutil)"
    )
    declare -A dict=(
        [pkg]='com.apple.pkg.CLTools_Executables'
    )
    "${app[pkgutil]}" --pkgs="${dict[pkg]}" >/dev/null || return 1
    # shellcheck disable=SC2016
    dict[str]="$( \
        "${app[pkgutil]}" --pkg-info="${dict[pkg]}" \
            | "${app[awk]}" '/version:/ {print $2}' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
    return 0
}
