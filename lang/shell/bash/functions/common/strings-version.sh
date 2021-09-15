#!/usr/bin/env bash

koopa:::pkg_config_version() { # {{{1
    # """
    # Get a library version via pkg-config.
    # @note Updated 2021-05-24.
    # """
    local pkg pkg_config x
    koopa::assert_has_args_eq "$#" 1
    pkg="${1:?}"
    pkg_config="$(koopa::locate_pkg_config)"
    x="$("$pkg_config" --modversion "$pkg")"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0

}

koopa::anaconda_version() { # {{{
    # """
    # Anaconda verison.
    # @note Updated 2021-05-24.
    # """
    local awk conda grep x
    koopa::assert_has_no_args "$#"
    awk="$(koopa::locate_awk)"
    conda="$(koopa::locate_conda)"
    grep="$(koopa::locate_grep)"
    koopa::is_anaconda || return 1
    # shellcheck disable=SC2016
    x="$( \
        "$conda" list 'anaconda' \
            | "$grep" -E '^anaconda ' \
            | "$awk" '{print $2}' \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::armadillo_version() { # {{{1
    # """
    # Armadillo: C++ library for linear algebra & scientific computing.
    # @note Updated 2021-03-01.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::pkg_config_version 'armadillo'
}

koopa::boost_version() { # {{{1
    # """
    # Boost (libboost) version.
    # @note Updated 2021-05-24.
    #
    # Extract the Boost library version using GCC preprocessing. This approach
    # is nice because it doesn't hardcode to a specific file path.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3708706/
    # - https://stackoverflow.com/questions/4518584/
    # """
    local bc brew_prefix gcc gcc_args grep major minor patch x
    koopa::assert_has_no_args "$#"
    bc="$(koopa::locate_bc)"
    gcc="$(koopa::locate_gcc)"
    grep="$(koopa::locate_grep)"
    gcc_args=()
    if koopa::is_macos
    then
        brew_prefix="$(koopa::homebrew_prefix)"
        gcc_args+=("-I${brew_prefix}/opt/boost/include")
    fi
    gcc_args+=(
        '-x' 'c++'
        '-E' '-'
    )
    x="$( \
        koopa::print '#include <boost/version.hpp>\nBOOST_VERSION' \
        | "$gcc" "${gcc_args[@]}" \
        | "$grep" -E '^[0-9]+$' \
    )"
    [[ -n "$x" ]] || return 1
    # Convert '107500' to '1.75.0', for example.
    major="$(koopa::print "$x / 100000" | "$bc")"
    minor="$(koopa::print "$x / 100 % 1000" | "$bc")"
    patch="$(koopa::print "$x % 100" | "$bc")"
    koopa::print "${major}.${minor}.${patch}"
    return 0
}

koopa::cairo_version() { # {{{1
    # """
    # Cairo (libcairo) version.
    # @note Updated 2021-03-01.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::pkg_config_version 'cairo'
}

koopa::current_bcbio_nextgen_version() { # {{{1
    # """
    # Get the latest bcbio-nextgen stable release version.
    # @note Updated 2021-06-11.
    #
    # This approach checks for latest stable release available via bioconda.
    # """
    local curl cut grep url x
    koopa::assert_has_no_args "$#"
    curl="$(koopa::locate_curl)"
    cut="$(koopa::locate_cut)"
    grep="$(koopa::locate_grep)"
    url="https://raw.githubusercontent.com/bcbio/bcbio-nextgen\
/master/requirements-conda.txt"
    x="$( \
        "$curl" --silent "$url" \
            | "$grep" 'bcbio-nextgen=' \
            | "$cut" -d '=' -f 2 \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::current_bioconductor_version() { # {{{1
    # """
    # Current Bioconductor version.
    # @note Updated 2021-05-24.
    # """
    local curl x
    koopa::assert_has_no_args "$#"
    curl="$(koopa::locate_curl)"
    x="$("$curl" --silent 'https://bioconductor.org/bioc-version')"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::current_ensembl_version() { # {{{1
    # """
    # Current Ensembl version.
    # @note Updated 2021-05-24.
    # """
    local curl cut sed x
    koopa::assert_has_no_args "$#"
    curl="$(koopa::locate_curl)"
    cut="$(koopa::locate_cut)"
    sed="$(koopa::locate_sed)"
    x="$( \
        "$curl" --silent 'ftp://ftp.ensembl.org/pub/current_README' \
        | "$sed" -n '3p' \
        | "$cut" -d ' ' -f 3 \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::current_flybase_version() { # {{{1
    # """
    # Current FlyBase version.
    # @note Updated 2021-05-24.
    # """
    local curl cut dmel grep head sort tail url x
    curl="$(koopa::locate_curl)"
    cut="$(koopa::locate_cut)"
    grep="$(koopa::locate_grep)"
    head="$(koopa::locate_head)"
    sort="$(koopa::locate_sort)"
    tail="$(koopa::locate_tail)"
    url='ftp://ftp.flybase.net/releases'
    dmel=0
    while (("$#"))
    do
        case "$1" in
            --dmel)
                dmel=1
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    if [[ "$dmel" -eq 1 ]]
    then
        x="$( \
            "$curl" --list-only --silent "${url}/current/" \
            | "$grep" -E '^dmel_r[.0-9]+$' \
            | "$head" -n 1 \
            | "$cut" -d '_' -f 2 \
        )"
    else
        x="$( \
            "$curl" --list-only --silent "${url}/" \
            | "$grep" -E '^FB[0-9]{4}_[0-9]{2}$' \
            | "$sort" \
            | "$tail" -n 1 \
        )"
    fi
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::current_gencode_version() { # {{{1
    # """
    # Current GENCODE version.
    # @note Updated 2021-05-24.
    # """
    local base_url curl cut grep head organism pattern short_name url x
    koopa::assert_has_args_le "$#" 1
    curl="$(koopa::locate_curl)"
    cut="$(koopa::locate_cut)"
    grep="$(koopa::locate_grep)"
    head="$(koopa::locate_head)"
    organism="${1:-Homo sapiens}"
    case "$organism" in
        'Homo sapiens')
            short_name='human'
            pattern='Release [0-9]+'
            ;;
        'Mus musculus')
            short_name='mouse'
            pattern='Release M[0-9]+'
            ;;
        *)
            koopa::stop "Unsupported organism: '${organism}'."
            ;;
    esac
    base_url='https://www.gencodegenes.org'
    url="${base_url}/${short_name}/"
    x="$( \
        "$curl" --silent "$url" \
        | "$grep" -Eo "$pattern" \
        | "$head" -n 1 \
        | "$cut" -d ' ' -f 2 \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::current_refseq_version() { # {{{1
    # """
    # Current RefSeq version.
    # @note Updated 2021-05-24.
    # """
    local curl url version
    koopa::assert_has_no_args "$#"
    curl="$(koopa::locate_curl)"
    url='ftp://ftp.ncbi.nlm.nih.gov/refseq/release/RELEASE_NUMBER'
    version="$("$curl" --silent "$url")"
    [[ -n "$version" ]] || return 1
    koopa::print "$version"
    return 0
}

koopa::current_wormbase_version() { # {{{1
    # """
    # Current WormBase version.
    # @note Updated 2021-05-24.
    # """
    local curl cut grep url version
    koopa::assert_has_no_args "$#"
    curl="$(koopa::locate_curl)"
    cut="$(koopa::locate_cut)"
    grep="$(koopa::locate_grep)"
    url="ftp://ftp.wormbase.org/pub/wormbase/\
releases/current-production-release"
    version="$( \
        "$curl" --list-only --silent "${url}/" | \
        "$grep" -Eo 'letter.WS[0-9]+' | \
        "$cut" -d '.' -f 2 \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$version"
    return 0
}

koopa::eigen_version() { # {{{1
    # """
    # Eigen (libeigen) version.
    # @note Updated 2021-03-01.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::pkg_config_version 'eigen3'
}

koopa::emacs_version() { # {{{1
    # """
    # Emacs version.
    # @note Updated 2021-09-15.
    # """
    local emacs
    emacs="$(koopa::locate_emacs)"
    koopa::get_version "$emacs"
}

koopa::extract_version() { # {{{1
    # """
    # Extract version number.
    # @note Updated 2021-05-24.
    # """
    local arg grep head pattern x
    koopa::assert_has_args "$#"
    grep="$(koopa::locate_grep)"
    head="$(koopa::locate_head)"
    pattern="$(koopa::version_pattern)"
    for arg in "$@"
    do
        x="$( \
            koopa::print "$arg" \
                | "$grep" -Eo "$pattern" \
                | "$head" -n 1 \
        )"
        [[ -n "$x" ]] || return 1
        koopa::print "$x"
    done
    return 0
}

koopa::gcc_version() { # {{{1
    # """
    # GCC version.
    # @note Updated 2021-05-24.
    # """
    local x
    koopa::assert_has_no_args "$#"
    gcc="$(koopa::locate_gcc)"
    x="$(koopa::return_version "$gcc")"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::get_version() { # {{{1
    # """
    # Get the version of an installed program.
    # @note Updated 2020-07-05.
    # """
    local cmd fun x
    koopa::assert_has_args "$#"
    for cmd in "$@"
    do
        fun="koopa::$(koopa::snake_case_simple "$cmd")_version"
        if koopa::is_function "$fun"
        then
            x="$("$fun")"
        else
            x="$(koopa::return_version "$cmd")"
        fi
        [[ -n "$x" ]] || return 1
        koopa::print "$x"
    done
    return 0
}

koopa::github_latest_release() { # {{{1
    # """
    # Get the latest release version from GitHub.
    # @note Updated 2021-05-24.
    #
    # @examples
    # koopa::github_latest_release 'acidgenomics/koopa'
    # # Expected failure:
    # koopa::github_latest_release 'acidgenomics/acidgenomics.github.io'
    # """
    local curl cut grep json repo sed url x
    koopa::assert_has_args "$#"
    curl="$(koopa::locate_curl)"
    cut="$(koopa::locate_cut)"
    grep="$(koopa::locate_grep)"
    sed="$(koopa::locate_sed)"
    repo="${1:?}"
    url="https://api.github.com/repos/${repo}/releases/latest"
    json="$("$curl" -s "$url" 2>&1 || true)"
    [[ -n "$json" ]] || return 1
    x="$( \
        koopa::print "$json" \
            | "$grep" '"tag_name":' \
            | "$cut" -d '"' -f 4 \
            | "$sed" 's/^v//' \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::harfbuzz_version() { # {{{1
    # """
    # Harfbuzz (libharfbuzz) version.
    # @note Updated 2021-03-01.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::pkg_config_version 'harfbuzz'
}

koopa::hdf5_version() { # {{{1
    # """
    # HDF5 version.
    # @note Updated 2021-05-24.
    #
    # Debian: 'dpkg -s libhdf5-dev'
    # """
    local grep sed x
    koopa::assert_has_no_args "$#"
    grep="$(koopa::locate_grep)"
    sed="$(koopa::locate_sed)"
    koopa::assert_is_installed 'h5cc'
    x="$( \
        h5cc -showconfig \
            | "$grep" 'HDF5 Version:' \
            | "$sed" -E 's/^(.+): //' \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::icu4c_version() { # {{{1
    # """
    # ICU version.
    # C/C++ and Java libraries for Unicode and globalization.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::pkg_config_version 'icu-uc'
}

koopa::imagemagick_version() { # {{{1
    # """
    # ImageMagick version.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::pkg_config_version 'ImageMagick'
}

koopa::koopa_version() { # {{{1
    # """
    # Koopa version.
    # @note Updated 2020-06-29.
    # """
    koopa::assert_has_no_args "$#"
    koopa::variable 'koopa-version'
    return 0
}

koopa::llvm_version() { # {{{1
    # """
    # LLVM version.
    # @note Updated 2021-09-15.
    # """
    local app x
    koopa::assert_has_no_args "$#"
    app="$(koopa::locate_llvm_config)"
    x="$(koopa::return_version "$app")"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::lmod_version() { # {{{1
    # """
    # Lmod version.
    # @note Updated 2020-06-29.
    #
    # Alterate approach:
    # > module --version 2>&1 \
    # >     | grep -Eo 'Version [.0-9]+' \
    # >     | cut -d ' ' -f 2
    # """
    local x
    koopa::assert_has_no_args "$#"
    x="${LMOD_VERSION:-}"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::openjdk_version() { # {{{1
    # """
    # Java (OpenJDK) version.
    # @note Updated 2021-05-24.
    # """
    local cut head x
    koopa::assert_has_no_args "$#"
    cut="$(koopa::locate_cut)"
    head="$(koopa::locate_head)"
    koopa::assert_is_installed 'java'
    x="$( \
        java --version \
            | "$head" -n 1 \
            | "$cut" -d ' ' -f 2 \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::oracle_instantclient_version() { # {{{1
    # """
    # Oracle InstantClient version.
    # @note Updated 2021-05-24.
    # """
    local grep x
    koopa::assert_has_no_args "$#"
    grep="$(koopa::locate_grep)"
    koopa::assert_is_installed 'sqlplus'
    x="$(sqlplus -v | "$grep" -E '^Version')"
    x="$(koopa::extract_version "$x")"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::os_version() { # {{{1
    # """
    # Operating system version.
    # @note Updated 2021-05-24.
    #
    # 'uname' returns Darwin kernel version for macOS.
    # """
    local x
    koopa::assert_has_no_args "$#"
    x=''
    if koopa::is_linux
    then
        x="$(koopa::linux_version)"
    elif koopa::is_macos
    then
        x="$(koopa::macos_version)"
    fi
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::parallel_version() { # {{{1
    # """
    # GNU parallel version.
    # @note Updated 2021-05-24.
    # """
    local cut head parallel x
    koopa::assert_has_no_args "$#"
    cut="$(koopa::locate_cut)"
    head="$(koopa::locate_head)"
    parallel="$(koopa::locate_parallel)"
    x="$( \
        "$parallel" --version \
            | "$head" -n 1 \
            | "$cut" -d ' ' -f 3 \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::perl_file_rename_version() { # {{{1
    # """
    # Perl File::Rename version.
    # @note Updated 2021-05-24.
    # """
    local head rename x
    koopa::assert_has_no_args "$#"
    head="$(koopa::locate_head)"
    rename="$(koopa::locate_rename)"
    x="$( \
        "$rename" --version 2>/dev/null \
        | "$head" -n 1 \
    )"
    koopa::str_match "$x" 'File::Rename' || return 1
    koopa::extract_version "$x"
    return 0
}

koopa::r_package_version() { # {{{1
    # """
    # R package version.
    # @note Updated 2021-05-24.
    # """
    local r rscript vec x
    koopa::assert_has_args "$#"
    r="$(koopa::locate_r)"
    rscript="${r}script"
    koopa::assert_is_installed "$rscript"
    pkgs=("$@")
    koopa::assert_is_r_package_installed "${pkgs[@]}"
    vec="$(koopa::array_to_r_vector "${pkgs[@]}")"
    x="$( \
        "$rscript" -e " \
            cat(vapply( \
                X = ${vec}, \
                FUN = function(x) { \
                    as.character(packageVersion(x)) \
                }, \
                FUN.VALUE = character(1L) \
            ), sep = '\n') \
        " \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::r_version() { # {{{1
    # """
    # R version.
    # @note Updated 2021-03-01.
    # """
    local head r x
    koopa::assert_has_args_le "$#" 1
    head="$(koopa::locate_head)"
    r="${1:-}"
    [[ -z "$r" ]] && r="$(koopa::locate_r)"
    x="$( \
        "$r" --version 2>/dev/null \
        | head -n 1 \
    )"
    if koopa::str_match "$x" 'R Under development (unstable)'
    then
        x='devel'
    else
        x="$(koopa::extract_version "$x")"
    fi
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::return_version() { # {{{1
    # """
    # Return version (via extraction).
    # @note Updated 2021-08-31.
    # """
    local cmd flag x
    koopa::assert_has_args_le "$#" 2
    cmd="${1:?}"
    flag="${2:-}"
    case "$cmd" in
        aspera-connect)
            cmd='ascp'
            ;;
        aws-cli)
            cmd='aws'
            ;;
        azure-cli)
            cmd='az'
            ;;
        bcbio-nextgen)
            cmd='bcbio_nextgen.py'
            ;;
        binutils)
            # > cmd='ld'  # doesn't work on macOS with Homebrew.
            cmd='dlltool'
            ;;
        coreutils)
            cmd='env'
            ;;
        du-dust)
            cmd='dust'
            ;;
        fd-find)
            cmd='fd'
            ;;
        findutils)
            cmd='find'
            ;;
        gdal)
            # Changed from 'gdalinfo' to 'gdal-config' in 3.2.0.
            cmd='gdal-config'
            ;;
        geos)
            cmd='geos-config'
            ;;
        gnupg)
            cmd='gpg'
            ;;
        google-cloud-sdk)
            cmd='gcloud'
            ;;
        gsl)
            cmd='gsl-config'
            ;;
        homebrew)
            cmd='brew'
            ;;
        icu)
            cmd='icu-config'
            ;;
        ncurses)
            cmd='ncurses6-config'
            ;;
        neovim)
            cmd='nvim'
            ;;
        openssh)
            cmd='ssh'
            ;;
        pip)
            cmd='pip3'
            ;;
        python)
            cmd="$(koopa::locate_python)"
            ;;
        ranger-fm)
            cmd='ranger'
            ;;
        ripgrep)
            cmd='rg'
            ;;
        ripgrep-all)
            cmd='rga'
            ;;
        rust)
            cmd='rustc'
            ;;
        sqlite)
            cmd='sqlite3'
            ;;
        subversion)
            cmd='svn'
            ;;
        tealdeer)
            cmd='tldr'
            ;;
        texinfo)
            cmd='makeinfo'
            ;;
        the-silver-searcher)
            cmd='ag'
            ;;
    esac
    if [[ -z "${flag:-}" ]]
    then
        case "$cmd" in
            docker-credential-pass)
                flag='version'
                ;;
            go)
                flag='version'
                ;;
            lua)
                flag='-v'
                ;;
            openssl)
                flag='version'
                ;;
            rstudio-server)
                flag='version'
                ;;
            ssh)
                flag='-V'
                ;;
            singularity)
                flag='version'
                ;;
            tmux)
                flag='-V'
                ;;
            *)
                flag='--version'
                ;;
        esac
    fi
    koopa::is_installed "$cmd" || return 1
    x="$("$cmd" "$flag" 2>&1 || true)"
    [[ -n "$x" ]] || return 1
    koopa::extract_version "$x"
    return 0
}

koopa::ruby_api_version() { # {{{1
    # """
    # Ruby API version.
    # @note Updated 2021-06-07.
    #
    # Used by Homebrew Ruby for default gem installation path.
    # See 'brew info ruby' for details.
    # """
    local x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed 'ruby'
    x="$(ruby -e 'print Gem.ruby_api_version')"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::sanitize_version() { # {{{1
    # """
    # Sanitize version.
    # @note Updated 2020-07-14.
    # @examples
    # koopa::sanitize_version '2.7.1p83'
    # ## 2.7.1
    # """
    local pattern x
    koopa::assert_has_args "$#"
    pattern='[.0-9]+'
    for x in "$@"
    do
        koopa::str_match_regex "$x" "$pattern" || return 1
        x="$(koopa::sub '^([.0-9]+).*$' '\1' "$x")"
        koopa::print "$x"
    done
    return 0
}

koopa::tex_version() { # {{{1
    # """
    # TeX version.
    # @note Updated 2021-05-24.
    #
    # We're checking the TeX Live release year here.
    # Here's what it looks like on Debian/Ubuntu:
    # TeX 3.14159265 (TeX Live 2017/Debian)
    # """
    local x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed 'tex'
    cut="$(koopa::locate_cut)"
    head="$(koopa::locate_head)"
    x="$( \
        tex --version \
            | "$head" -n 1 \
            | "$cut" -d '(' -f 2 \
            | "$cut" -d ')' -f 1 \
            | "$cut" -d ' ' -f 3 \
            | "$cut" -d '/' -f 1 \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::version_pattern() { # {{{1
    # """
    # Version pattern.
    # @note Updated 2020-07-14.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print '[0-9]+\.[0-9]+(\.[0-9]+)?(\.[0-9]+)?([a-z])?([0-9]+)?'
    return 0
}

koopa::vim_version() { # {{{1
    # """
    # Vim version.
    # @note Updated 2021-05-24.
    # """
    local cut grep head major_minor patch version x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed 'vim'
    cut="$(koopa::locate_cut)"
    grep="$(koopa::locate_grep)"
    head="$(koopa::locate_head)"
    x="$(vim --version 2>/dev/null)"
    major_minor="$( \
        koopa::print "$x" \
            | "$head" -n 1 \
            | "$cut" -d ' ' -f 5 \
    )"
    if koopa::str_match "$x" 'Included patches:'
    then
        patch="$( \
            koopa::print "$x" \
                | "$grep" 'Included patches:' \
                | "$cut" -d '-' -f 2 \
                | "$cut" -d ',' -f 1 \
        )"
        version="${major_minor}.${patch}"
    else
        version="$major_minor"
    fi
    koopa::print "$version"
    return 0
}
