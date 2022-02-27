#!/usr/bin/env bash

koopa_anaconda_version() { # {{{
    # """
    # Anaconda verison.
    # @note Updated 2022-02-25.
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [conda]="$(koopa_locate_anaconda)"
    )
    koopa_is_anaconda "${app[conda]}" || return 1
    # shellcheck disable=SC2016
    str="$( \
        "${app[conda]}" list 'anaconda' \
            | koopa_grep \
                --extended-regexp \
                --pattern='^anaconda ' \
            | "${app[awk]}" '{print $2}' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

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
        | koopa_grep --extended-regexp --pattern='^[0-9]+$' \
    )"
    [[ -n "${dict[version]}" ]] || return 1
    # Convert '107500' to '1.75.0', for example.
    dict[major]="$(koopa_print "${dict[version]} / 100000" | "${app[bc]}")"
    dict[minor]="$(koopa_print "${dict[version]} / 100 % 1000" | "${app[bc]}")"
    dict[patch]="$(koopa_print "${dict[version]} % 100" | "${app[bc]}")"
    koopa_print "${dict[major]}.${dict[minor]}.${dict[patch]}"
    return 0
}

koopa_bpytop_version() { # {{{1
    # """
    # bpytop version.
    # @note Updated 2022-02-25.
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [bpytop]="$(koopa_locate_bpytop)"
    )
    # shellcheck disable=SC2016
    str="$( \
        "${app[bpytop]}" --version \
            | koopa_grep --pattern='bpytop version:' \
            | "${app[awk]}" '{ print $NF }' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
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

koopa_conda_version() { # {{{1
    # """
    # Conda version.
    # @note Updated 2022-01-21.
    # """
    koopa_assert_has_no_args "$#"
    koopa_get_version "$(koopa_locate_conda)"
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
        | koopa_grep --extended-regexp --pattern='^FB[0-9]{4}_[0-9]{2}$' \
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
            --extended-regexp \
            --only-matching \
            --pattern="${dict[pattern]}" \
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
                --extended-regexp \
                --only-matching \
                --pattern='letter.WS[0-9]+' \
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

koopa_emacs_version() { # {{{1
    # """
    # Emacs version.
    # @note Updated 2022-01-20.
    # """
    koopa_assert_has_no_args "$#"
    koopa_get_version "$(koopa_locate_emacs)"
}

koopa_extract_version() { # {{{1
    # """
    # Extract version number.
    # @note Updated 2022-02-27.
    #
    # @examples
    # > koopa_extract_version "$(bash --version)"
    # # 5.1.16
    # """
    local app arg dict
    declare -A app=(
        [head]="$(koopa_locate_head)"
    )
    declare -A dict=(
        [pattern]="$(koopa_version_pattern)"
    )
    if [[ "$#" -eq 0 ]]
    then
        args=("$(</dev/stdin)")
    else
        args=("$@")
    fi
    for arg in "${args[@]}"
    do
        local str
        str="$( \
            koopa_grep \
                --extended-regexp \
                --only-matching \
                --pattern="${dict[pattern]}" \
                --string="$arg" \
            | "${app[head]}" --lines=1 \
        )"
        [[ -n "$str" ]] || return 1
        koopa_print "$str"
    done
    return 0
}

koopa_gcc_version() { # {{{1
    # """
    # GCC version.
    # @note Updated 2022-01-20.
    # """
    koopa_assert_has_no_args "$#"
    koopa_get_version "$(koopa_locate_gcc)"
}

koopa_get_version() { # {{{1
    # """
    # Get the version of an installed program.
    # @note Updated 2022-02-23.
    # """
    local cmd
    koopa_assert_has_args "$#"
    for cmd in "$@"
    do
        local fun str
        fun="koopa_$(koopa_snake_case_simple "$cmd")_version"
        if koopa_is_function "$fun"
        then
            str="$("$fun")"
        else
            str="$(koopa_return_version "$cmd")"
        fi
        [[ -n "$str" ]] || return 1
        koopa_print "$str"
    done
    return 0
}

koopa_get_version_from_pkg_config() { # {{{1
    # """
    # Get a library version via pkg-config.
    # @note Updated 2022-02-27.
    # """
    local app pkg str
    koopa_assert_has_args_eq "$#" 1
    pkg="${1:?}"
    declare -A app=(
        [pkg_config]="$(koopa_locate_pkg_config)"
    )
    str="$("${app[pkg_config]}" --modversion "$pkg")"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_github_latest_release() { # {{{1
    # """
    # Get the latest release version from GitHub.
    # @note Updated 2022-02-27.
    #
    # @examples
    # > koopa_github_latest_release 'acidgenomics/koopa'
    # """
    local app repo str url
    koopa_assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [sed]="$(koopa_locate_sed)"
    )
    repo="${1:?}"
    url="https://api.github.com/repos/${repo}/releases/latest"
    str="$( \
        koopa_parse_url "$url" \
            | koopa_grep --pattern='"tag_name":' \
            | "${app[cut]}" --delimiter='"' --fields='4' \
            | "${app[sed]}" 's/^v//' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_harfbuzz_version() { # {{{1
    # """
    # Harfbuzz (libharfbuzz) version.
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

koopa_lesspipe_version() { # {{{1
    # """
    # lesspipe.sh version.
    # @note Updated 2022-02-23.
    # """
    local app str
    declare -A app=(
        [cat]="$(koopa_locate_cat)"
        [lesspipe]="$(koopa_locate_lesspipe)"
        [sed]="$(koopa_locate_sed)"
    )
    str="$( \
        "${app[cat]}" "${app[lesspipe]}" \
            | "${app[sed]}" --quiet '2p' \
            | koopa_extract_version \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_llvm_version() { # {{{1
    # """
    # LLVM version.
    # @note Updated 2022-01-20.
    # """
    koopa_assert_has_no_args "$#"
    koopa_get_version "$(koopa_locate_llvm_config)"
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

koopa_mamba_version() { # {{{1
    # """
    # Mamba version.
    # @note Updated 2022-01-21.
    # """
    koopa_assert_has_no_args "$#"
    koopa_get_version "$(koopa_locate_mamba)"
}

koopa_openjdk_version() { # {{{1
    # """
    # Java (OpenJDK) version.
    # @note Updated 2022-02-27.
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
        [java]="$(koopa_locate_java)"
    )
    str="$( \
        "${app[java]}" --version \
            | "${app[head]}" --lines=1 \
            | "${app[cut]}" --delimiter=' ' --fields='2' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
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
            | koopa_grep --extended-regexp --pattern='^Version' \
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

koopa_parallel_version() { # {{{1
    # """
    # GNU parallel version.
    # @note Updated 2022-02-27.
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
        [parallel]="$(koopa_locate_parallel)"
    )
    str="$( \
        "${app[parallel]}" --version \
            | "${app[head]}" --lines=1 \
            | "${app[cut]}" --delimiter=' ' --fields='3' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_perl_file_rename_version() { # {{{1
    # """
    # Perl File::Rename version.
    # @note Updated 2022-02-27.
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
        [rename]="$(koopa_locate_rename)"
    )
    str="$( \
        "${app[rename]}" --version 2>/dev/null \
            | "${app[head]}" --lines=1 \

    )"
    # Ensure we're detecting the Perl module.
    koopa_str_detect_fixed \
        --string="$str" \
        --pattern='File::Rename' \
        || return 1
    str="$( \
        koopa_print "$str" \
            | "${app[cut]}" --delimiter=' ' --fields='5' \
            | koopa_extract_version \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_r_package_version() { # {{{1
    # """
    # R package version.
    # @note Updated 2022-02-27.
    #
    # @examples
    # > koopa_r_package_version 'basejump'
    # """
    local app str vec
    koopa_assert_has_args "$#"
    declare -A app=(
        [rscript]="$(koopa_locate_rscript)"
    )
    pkgs=("$@")
    koopa_is_r_package_installed "${pkgs[@]}" || return 1
    vec="$(koopa_r_paste_to_vector "${pkgs[@]}")"
    str="$( \
        "${app[rscript]}" -e " \
            cat(vapply( \
                X = ${vec}, \
                FUN = function(x) { \
                    as.character(packageVersion(x)) \
                }, \
                FUN.VALUE = character(1L) \
            ), sep = '\n') \
        " \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_r_version() { # {{{1
    # """
    # R version.
    # @note Updated 2022-02-27.
    # """
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [head]="$(koopa_locate_head)"
        [r]="${1:-}"
    )
    [[ -z "${app[r]}" ]] && app[r]="$(koopa_locate_r)"
    str="$( \
        "${app[r]}" --version 2>/dev/null \
        | "${app[head]}" --lines=1 \
    )"
    if koopa_str_detect_fixed \
        --string="$str" \
        --pattern='R Under development (unstable)'
    then
        str='devel'
    else
        str="$(koopa_extract_version "$str")"
    fi
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_return_version() { # {{{1
    # """
    # Return version (via extraction).
    # @note Updated 2022-02-27.
    # """
    local app dict
    koopa_assert_has_args_le "$#" 2
    declare -A app=(
        [cmd]="${1:?}"
    )
    declare -A dict=(
        [cmd_name]="$(koopa_basename "${app[cmd]}")"
        [flag]="${2:-}"
    )
    if [[ ! -x "${app[cmd]}" ]]
    then
        case "${dict[cmd_name]}" in
            'aspera-connect')
                app[cmd]='ascp'
                ;;
            'aws-cli')
                app[cmd]='aws'
                ;;
            'azure-cli')
                app[cmd]='az'
                ;;
            'bcbio-nextgen')
                app[cmd]='bcbio_nextgen.py'
                ;;
            'binutils')
                # Checking against 'ld' doesn't work on macOS with Homebrew.
                app[cmd]='dlltool'
                ;;
            'coreutils')
                app[cmd]='env'
                ;;
            'du-dust')
                app[cmd]='dust'
                ;;
            'fd-find')
                app[cmd]='fd'
                ;;
            'findutils')
                app[cmd]='find'
                ;;
            'gdal')
                app[cmd]='gdal-config'
                ;;
            'geos')
                app[cmd]='geos-config'
                ;;
            'gnupg')
                app[cmd]='gpg'
                ;;
            'google-cloud-sdk')
                app[cmd]='gcloud'
                ;;
            'gsl')
                app[cmd]='gsl-config'
                ;;
            'homebrew')
                app[cmd]='brew'
                ;;
            'icu')
                app[cmd]='icu-config'
                ;;
            'ncurses')
                app[cmd]='ncurses6-config'
                ;;
            'neovim')
                app[cmd]='nvim'
                ;;
            'openssh')
                app[cmd]='ssh'
                ;;
            'password-store')
                app[cmd]='pass'
                ;;
            'pcre2')
                app[cmd]='pcre2-config'
                ;;
            'pip')
                app[cmd]='pip3'
                ;;
            'python')
                app[cmd]='python3'
                ;;
            'ranger-fm')
                app[cmd]='ranger'
                ;;
            'ripgrep')
                app[cmd]='rg'
                ;;
            'ripgrep-all')
                app[cmd]='rga'
                ;;
            'rust')
                app[cmd]='rustc'
                ;;
            'sqlite')
                app[cmd]='sqlite3'
                ;;
            'subversion')
                app[cmd]='svn'
                ;;
            'tealdeer')
                app[cmd]='tldr'
                ;;
            'texinfo')
                # TeX Live install can mask this on macOS.
                app[cmd]='texi2any'
                ;;
            'the-silver-searcher')
                app[cmd]='ag'
                ;;
        esac
    fi
    if [[ -z "${dict[flag]}" ]]
    then
        case "${dict[cmd_name]}" in
            'docker-credential-pass' | \
            'go' | \
            'openssl' | \
            'rstudio-server' | \
            'singularity')
                dict[flag]='version'
                ;;
            'lua')
                dict[flag]='-v'
                ;;
            'openssh' | \
            'ssh' | \
            'tmux')
                dict[flag]='-V'
                ;;
            *)
                dict[flag]='--version'
                ;;
        esac
    fi
    koopa_is_installed "${app[cmd]}" || return 1
    dict[str]="$("${app[cmd]}" "${dict[flag]}" 2>&1 || true)"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_extract_version "${dict[str]}"
    return 0
}

koopa_ruby_api_version() { # {{{1
    # """
    # Ruby API version.
    # @note Updated 2022-02-27.
    #
    # Used by Homebrew Ruby for default gem installation path.
    # See 'brew info ruby' for details.
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [ruby]="$(koopa_locate_ruby)"
    )
    str="$("${app[ruby]}" -e 'print Gem.ruby_api_version')"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_sanitize_version() { # {{{1
    # """
    # Sanitize version.
    # @note Updated 2022-02-27.
    #
    # @examples
    # > koopa_sanitize_version '2.7.1p83'
    # # 2.7.1
    # """
    local str
    koopa_assert_has_args "$#"
    for str in "$@"
    do
        koopa_str_detect_regex \
            --string="$str" \
            --pattern='[.0-9]+' \
            || return 1
        str="$( \
            koopa_sub \
                --pattern='^([.0-9]+).*$' \
                --replacement='\1' \
                "$str" \
        )"
        koopa_print "$str"
    done
    return 0
}

koopa_tex_version() { # {{{1
    # """
    # TeX version.
    # @note Updated 2022-02-27.
    #
    # We're checking the TeX Live release year here.
    # Here's what it looks like on Debian/Ubuntu:
    # TeX 3.14159265 (TeX Live 2017/Debian)
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
        [tex]="$(koopa_locate_tex)"
    )
    str="$( \
        "${app[tex]}" --version \
            | "${app[head]}" --lines=1 \
            | "${app[cut]}" --delimiter='(' --fields='2' \
            | "${app[cut]}" --delimiter=')' --fields='1' \
            | "${app[cut]}" --delimiter=' ' --fields='3' \
            | "${app[cut]}" --delimiter='/' --fields='1' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_version_pattern() { # {{{1
    # """
    # Version pattern.
    # @note Updated 2022-02-27.
    # """
    koopa_assert_has_no_args "$#"
    koopa_print '[0-9]+\.[0-9]+(\.[0-9]+)?(\.[0-9]+)?([a-z])?([0-9]+)?'
    return 0
}

koopa_vim_version() { # {{{1
    # """
    # Vim version.
    # @note Updated 2022-02-27.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
        [vim]="$(koopa_locate_vim)"
    )
    declare -A dict=(
        [str]="$("${app[vim]}" --version 2>/dev/null)"
    )
    dict[maj_min]="$( \
        koopa_print "${dict[str]}" \
            | "${app[head]}" --lines=1 \
            | "${app[cut]}" --delimiter=' ' --fields='5' \
    )"
    dict[out]="${dict[maj_min]}"
    if koopa_str_detect_fixed \
        --string="${dict[str]}" \
        --pattern='Included patches:'
    then
        dict[patch]="$( \
            koopa_print "${dict[str]}" \
                | koopa_grep --pattern='Included patches:' \
                | "${app[cut]}" --delimiter='-' --fields='2' \
                | "${app[cut]}" --delimiter=',' --fields='1' \
        )"
        dict[out]="${dict[out]}.${dict[patch]}"
    fi
    koopa_print "${dict[out]}"
    return 0
}

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
