#!/usr/bin/env bash

koopa:::pkg_config_version() { # {{{1
    # """
    # Get a library version via pkg-config.
    # @note Updated 2021-10-27.
    # """
    local app pkg x
    koopa::assert_has_args_eq "$#" 1
    pkg="${1:?}"
    declare -A app=(
        [pkg_config]="$(koopa::locate_pkg_config)"
    )
    x="$("${app[pkg_config]}" --modversion "$pkg")"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0

}

koopa::anaconda_version() { # {{{
    # """
    # Anaconda verison.
    # @note Updated 2021-10-26.
    # """
    local app x
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [awk]="$(koopa::locate_awk)"
        [conda]="$(koopa::locate_anaconda)"
    )
    koopa::is_anaconda "${app[conda]}" || return 1
    # shellcheck disable=SC2016
    x="$( \
        "${app[conda]}" list 'anaconda' \
            | koopa::grep --extended-regexp '^anaconda ' \
            | "${app[awk]}" '{print $2}' \
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
    # @note Updated 2021-10-25.
    #
    # Extract the Boost library version using GCC preprocessing. This approach
    # is nice because it doesn't hardcode to a specific file path.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3708706/
    # - https://stackoverflow.com/questions/4518584/
    # """
    local app brew_prefix gcc_args major minor patch x
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [bc]="$(koopa::locate_bc)"
        [gcc]="$(koopa::locate_gcc)"
    )
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
        | "${app[gcc]}" "${gcc_args[@]}" \
        | koopa::grep --extended-regexp '^[0-9]+$' \
    )"
    [[ -n "$x" ]] || return 1
    # Convert '107500' to '1.75.0', for example.
    major="$(koopa::print "$x / 100000" | "${app[bc]}")"
    minor="$(koopa::print "$x / 100 % 1000" | "${app[bc]}")"
    patch="$(koopa::print "$x % 100" | "${app[bc]}")"
    koopa::print "${major}.${minor}.${patch}"
    return 0
}

koopa::bpytop_version() { # {{{1
    # """
    # bpytop version.
    # @note Updated 2021-10-25.
    # """
    local app x
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [awk]="$(koopa::locate_awk)"
        [bpytop]="$(koopa::locate_bpytop)"
    )
    # shellcheck disable=SC2016
    x="$( \
        "${app[bpytop]}" --version \
            | koopa::grep 'bpytop version:' \
            | "${app[awk]}" '{ print $NF }' \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
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
    # @note Updated 2021-10-25.
    #
    # This approach checks for latest stable release available via bioconda.
    # """
    local app url x
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
    )
    url="https://raw.githubusercontent.com/bcbio/bcbio-nextgen\
/master/requirements-conda.txt"
    x="$( \
        koopa::parse_url "$url" \
            | koopa::grep 'bcbio-nextgen=' \
            | "${app[cut]}" -d '=' -f 2 \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::current_bioconductor_version() { # {{{1
    # """
    # Current Bioconductor version.
    # @note Updated 2021-10-25.
    # """
    local x
    koopa::assert_has_no_args "$#"
    x="$(koopa::parse_url 'https://bioconductor.org/bioc-version')"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::current_ensembl_version() { # {{{1
    # """
    # Current Ensembl version.
    # @note Updated 2021-10-25.
    # """
    local app x
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
        [sed]="$(koopa::locate_sed)"
    )
    x="$( \
        koopa::parse_url 'ftp://ftp.ensembl.org/pub/current_README' \
        | "${app[sed]}" -n '3p' \
        | "${app[cut]}" -d ' ' -f 3 \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::current_flybase_version() { # {{{1
    # """
    # Current FlyBase version.
    # @note Updated 2021-10-25.
    # """
    local app url x
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
        [head]="$(koopa::locate_head)"
        [tail]="$(koopa::locate_tail)"
    )
    url='ftp://ftp.flybase.net/releases'
    x="$( \
        koopa::parse_url --list-only "${url}/" \
        | koopa::grep --extended-regexp '^FB[0-9]{4}_[0-9]{2}$' \
        | "${app[tail]}" -n 1 \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::current_gencode_version() { # {{{1
    # """
    # Current GENCODE version.
    # @note Updated 2021-10-25.
    # """
    local app base_url organism pattern short_name url x
    koopa::assert_has_args_le "$#" 1
    declare -A app=(
        [curl]="$(koopa::locate_curl)"
        [cut]="$(koopa::locate_cut)"
        [grep]="$(koopa::locate_grep)"
        [head]="$(koopa::locate_head)"
    )
    organism="${1:-Homo sapiens}"
    case "$organism" in
        'Homo sapiens' | \
        'human')
            short_name='human'
            pattern='Release [0-9]+'
            ;;
        'Mus musculus' | \
        'mouse')
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
        koopa::parse_url "$url" \
        | koopa::grep \
            --extended-regexp \
            --only-matching \
            "$pattern" \
        | "${app[head]}" -n 1 \
        | "${app[cut]}" -d ' ' -f 2 \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::current_refseq_version() { # {{{1
    # """
    # Current RefSeq version.
    # @note Updated 2021-10-25.
    # """
    local url version
    koopa::assert_has_no_args "$#"
    url='ftp://ftp.ncbi.nlm.nih.gov/refseq/release/RELEASE_NUMBER'
    version="$(koopa::parse_url "$url")"
    [[ -n "$version" ]] || return 1
    koopa::print "$version"
    return 0
}

koopa::current_wormbase_version() { # {{{1
    # """
    # Current WormBase version.
    # @note Updated 2021-10-25.
    # """
    local app url version
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
    )
    url="ftp://ftp.wormbase.org/pub/wormbase/\
releases/current-production-release"
    version="$( \
        koopa::parse_url --list-only "${url}/" \
            | koopa::grep \
                --extended-regexp \
                --only-matching \
                'letter.WS[0-9]+' \
            | "${app[cut]}" -d '.' -f 2 \
    )"
    [[ -n "$version" ]] || return 1
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

# FIXME Consider adding support for pipe workflows here.
koopa::extract_version() { # {{{1
    # """
    # Extract version number.
    # @note Updated 2021-10-27.
    # """
    local app arg pattern x
    koopa::assert_has_args "$#"
    declare -A app=(
        [head]="$(koopa::locate_head)"
    )
    pattern="$(koopa::version_pattern)"
    for arg in "$@"
    do
        x="$( \
            koopa::print "$arg" \
                | koopa::grep \
                    --extended-regexp \
                    --only-matching \
                    "$pattern" \
                | "${app[head]}" -n 1 \
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
    # @note Updated 2021-10-25.
    #
    # @examples
    # koopa::github_latest_release 'acidgenomics/koopa'
    # """
    local app repo url x
    koopa::assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
        [sed]="$(koopa::locate_sed)"
    )
    repo="${1:?}"
    url="https://api.github.com/repos/${repo}/releases/latest"
    x="$( \
        koopa::parse_url "$url" \
            | koopa::grep '"tag_name":' \
            | "${app[cut]}" -d '"' -f 4 \
            | "${app[sed]}" 's/^v//' \
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
    # @note Updated 2021-10-27.
    #
    # Debian: 'dpkg -s libhdf5-dev'
    # """
    local app x
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [h5cc]="$(koopa::locate_h5cc)"
        [sed]="$(koopa::locate_sed)"
    )
    x="$( \
        "${app[h5cc]}" -showconfig \
            | koopa::grep 'HDF5 Version:' \
            | "${app[sed]}" -E 's/^(.+): //' \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

# FIXME This check seems to be failing on macOS.
# FIXME Need to update Homebrew configuration?
# Seeing this error, need to resolve:
# Package icu-uc was not found in the pkg-config search path.
# Perhaps you should add the directory containing `icu-uc.pc'
# to the PKG_CONFIG_PATH environment variable
# No package 'icu-uc' found

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

koopa::lesspipe_version() { # {{{1
    # """
    # lesspipe.sh version.
    # @note Updated 2021-11-11.
    # """
    local app x
    declare -A app=(
        [cat]="$(koopa::locate_cat)"
        [lesspipe]="$(koopa::locate_lesspipe)"
        [sed]="$(koopa::locate_sed)"
    )
    x="$( \
        "${app[cat]}" "${app[lesspipe]}" \
            | "${app[sed]}" -n '2 p' \
    )"
    x="$(koopa::extract_version "$x")"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
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
    # @note Updated 2021-10-26.
    # """
    local app x
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
        [head]="$(koopa::locate_head)"
        [java]="$(koopa::locate_java)"
    )
    x="$( \
        "${app[java]}" --version \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d ' ' -f 2 \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::oracle_instantclient_version() { # {{{1
    # """
    # Oracle InstantClient version.
    # @note Updated 2021-10-27.
    # """
    local app x
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [sqlplus]="$(koopa::locate_sqlplus)"
    )
    x="$( \
        "${app[sqlplus]}" -v \
            | koopa::grep --extended-regexp '^Version' \
    )"
    x="$(koopa::extract_version "$x")"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::os_version() { # {{{1
    # """
    # Operating system version.
    # @note Updated 2021-11-16.
    #
    # 'uname' returns Darwin kernel version for macOS.
    # """
    local x
    koopa::assert_has_no_args "$#"
    x=''
    if koopa::is_linux
    then
        x="$(koopa::linux_os_version)"
    elif koopa::is_macos
    then
        x="$(koopa::macos_os_version)"
    fi
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::parallel_version() { # {{{1
    # """
    # GNU parallel version.
    # @note Updated 2021-10-25.
    # """
    local app x
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
        [head]="$(koopa::locate_head)"
        [parallel]="$(koopa::locate_parallel)"
    )
    x="$( \
        "${app[parallel]}" --version \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d ' ' -f 3 \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::perl_file_rename_version() { # {{{1
    # """
    # Perl File::Rename version.
    # @note Updated 2021-10-25.
    # """
    local app x
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
        [head]="$(koopa::locate_head)"
        [rename]="$(koopa::locate_rename)"
    )
    x="$( \
        "${app[rename]}" --version 2>/dev/null \
            | "${app[head]}" -n 1 \
    )"
    koopa::str_match_fixed "$x" 'File::Rename' || return 1
    x="$( \
        koopa::print "$x" \
            | "${app[cut]}" -d ' ' -f 5 \
    )"
    x="$(koopa::extract_version "$x")"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::r_package_version() { # {{{1
    # """
    # R package version.
    # @note Updated 2021-10-29.
    # """
    local app vec x
    koopa::assert_has_args "$#"
    declare -A app=(
        [rscript]="$(koopa::locate_rscript)"
    )
    pkgs=("$@")
    koopa::assert_is_r_package_installed "${pkgs[@]}"
    vec="$(koopa::array_to_r_vector "${pkgs[@]}")"
    x="$( \
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
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::r_version() { # {{{1
    # """
    # R version.
    # @note Updated 2021-10-27.
    # """
    local app x
    koopa::assert_has_args_le "$#" 1
    declare -A app=(
        [head]="$(koopa::locate_head)"
        [r]="${1:-}"
    )
    [[ -z "${app[r]}" ]] && app[r]="$(koopa::locate_r)"
    x="$( \
        "${app[r]}" --version 2>/dev/null \
        | "${app[head]}" -n 1 \
    )"
    if koopa::str_match_fixed "$x" 'R Under development (unstable)'
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
    # @note Updated 2021-10-27.
    # """
    local cmd cmd_name flag x
    koopa::assert_has_args_le "$#" 2
    cmd="${1:?}"
    flag="${2:-}"
    cmd_name="$(koopa::basename "$cmd")"
    if [[ ! -x "$cmd" ]]
    then
        case "$cmd_name" in
            'aspera-connect')
                cmd='ascp'
                ;;
            'aws-cli')
                cmd='aws'
                ;;
            'azure-cli')
                cmd='az'
                ;;
            'bcbio-nextgen')
                cmd='bcbio_nextgen.py'
                ;;
            'binutils')
                # > cmd='ld'  # doesn't work on macOS with Homebrew.
                cmd='dlltool'
                ;;
            'coreutils')
                cmd='env'
                ;;
            'du-dust')
                cmd='dust'
                ;;
            'fd-find')
                cmd='fd'
                ;;
            'findutils')
                cmd='find'
                ;;
            'gdal')
                # Changed from 'gdalinfo' to 'gdal-config' in 3.2.0.
                cmd='gdal-config'
                ;;
            'geos')
                cmd='geos-config'
                ;;
            'gnupg')
                cmd='gpg'
                ;;
            'google-cloud-sdk')
                cmd='gcloud'
                ;;
            'gsl')
                cmd='gsl-config'
                ;;
            'homebrew')
                cmd='brew'
                ;;
            'icu')
                cmd='icu-config'
                ;;
            'ncurses')
                cmd='ncurses6-config'
                ;;
            'neovim')
                cmd='nvim'
                ;;
            'openssh')
                cmd='ssh'
                ;;
            'password-store')
                cmd='pass'
                ;;
            'pcre2')
                cmd='pcre2-config'
                ;;
            'pip')
                cmd='pip3'
                ;;
            'python')
                cmd='python3'
                ;;
            'ranger-fm')
                cmd='ranger'
                ;;
            'ripgrep')
                cmd='rg'
                ;;
            'ripgrep-all')
                cmd='rga'
                ;;
            'rust')
                cmd='rustc'
                ;;
            'sqlite')
                cmd='sqlite3'
                ;;
            'subversion')
                cmd='svn'
                ;;
            'tealdeer')
                cmd='tldr'
                ;;
            'texinfo')
                # NOTE Tex Live install can mask this on macOS.
                cmd='texi2any'
                ;;
            'the-silver-searcher')
                cmd='ag'
                ;;
        esac
    fi
    if [[ -z "${flag:-}" ]]
    then
        case "$cmd_name" in
            'docker-credential-pass' | \
            'go' | \
            'openssl' | \
            'rstudio-server' | \
            'singularity')
                flag='version'
                ;;
            'lua')
                flag='-v'
                ;;
            'openssh' | \
            'ssh' | \
            'tmux')
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
    # @note Updated 2021-10-25.
    #
    # Used by Homebrew Ruby for default gem installation path.
    # See 'brew info ruby' for details.
    # """
    local app x
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [ruby]="$(koopa::locate_ruby)"
    )
    x="$("${app[ruby]}" -e 'print Gem.ruby_api_version')"
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
    # @note Updated 2021-10-27.
    #
    # We're checking the TeX Live release year here.
    # Here's what it looks like on Debian/Ubuntu:
    # TeX 3.14159265 (TeX Live 2017/Debian)
    # """
    local app x
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
        [head]="$(koopa::locate_head)"
        [tex]="$(koopa::locate_tex)"
    )
    x="$( \
        "${app[tex]}" --version \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d '(' -f 2 \
            | "${app[cut]}" -d ')' -f 1 \
            | "${app[cut]}" -d ' ' -f 3 \
            | "${app[cut]}" -d '/' -f 1 \
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
    # @note Updated 2021-10-27.
    # """
    local app major_minor patch version vim x
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
        [head]="$(koopa::locate_head)"
        [vim]="$(koopa::locate_vim)"
    )
    x="$("${app[vim]}" --version 2>/dev/null)"
    major_minor="$( \
        koopa::print "$x" \
            | "${app[head]}" -n 1 \
            | "${app[cut]}" -d ' ' -f 5 \
    )"
    if koopa::str_match_fixed "$x" 'Included patches:'
    then
        patch="$( \
            koopa::print "$x" \
                | koopa::grep 'Included patches:' \
                | "${app[cut]}" -d '-' -f 2 \
                | "${app[cut]}" -d ',' -f 1 \
        )"
        version="${major_minor}.${patch}"
    else
        version="$major_minor"
    fi
    koopa::print "$version"
    return 0
}

koopa::xcode_clt_version() { # {{{1
    # """
    # Xcode CLT version.
    # @note Updated 2021-11-16.
    #
    # @seealso
    # - https://apple.stackexchange.com/questions/180957
    # - pkgutil --pkgs=com.apple.pkg.Xcode
    # """
    local app pkg x
    koopa::assert_has_no_args "$#"
    koopa::is_xcode_clt_installed || return 1
    declare -A app=(
        [awk]="$(koopa::locate_awk)"
        [pkgutil]="$(koopa::macos_locate_pkgutil)"
    )
    pkg='com.apple.pkg.CLTools_Executables'
    "${app[pkgutil]}" --pkgs="$pkg" >/dev/null || return 1
    # shellcheck disable=SC2016
    x="$( \
        "${app[pkgutil]}" --pkg-info="$pkg" \
            | "${app[awk]}" '/version:/ {print $2}' \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}
