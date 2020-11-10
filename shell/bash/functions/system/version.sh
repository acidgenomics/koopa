#!/usr/bin/env bash

koopa::anaconda_version() { # {{{
    # """
    # Anaconda verison.
    # @note Updated 2020-07-08.
    # """
    local x
    koopa::is_anaconda || return 1
    koopa::assert_is_installed awk grep
    x="$( \
        conda list 'anaconda' \
            | grep -E '^anaconda ' \
            | awk '{print $2}' \
    )"
    koopa::print "$x"
    return 0
}

koopa::armadillo_version() { # {{{1
    # """
    # Armadillo: C++ library for linear algebra & scientific computing.
    # @note Updated 2020-10-26.
    # """
    local x
    x="$(pkg-config --modversion armadillo)"
    koopa::print "$x"
    return 0
}

koopa::current_bcbio_version() { # {{{1
    # """
    # Get the latest bcbio-nextgen stable release version.
    # @note Updated 2020-06-30.
    #
    # This approach checks for latest stable release available via bioconda.
    # """
    local url x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed curl
    url="https://raw.githubusercontent.com/bcbio/bcbio-nextgen\
/master/requirements-conda.txt"
    x="$( \
        curl --silent "$url" \
            | grep 'bcbio-nextgen=' \
            | cut -d '=' -f 2 \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::current_bioc_version() { # {{{1
    # """
    # Current Bioconductor version.
    # @note Updated 2020-06-29.
    # """
    local x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed curl
    x="$(curl --silent 'https://bioconductor.org/bioc-version')"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::current_ensembl_version() { # {{{1
    # """
    # Current Ensembl version.
    # @note Updated 2020-07-01.
    # """
    local version
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed curl
    version="$( \
        curl --silent 'ftp://ftp.ensembl.org/pub/current_README' \
        | sed -n 3p \
        | cut -d ' ' -f 3 \
    )"
    koopa::print "$version"
    return 0
}

koopa::current_flybase_version() { # {{{1
    # """
    # Current FlyBase version.
    # @note Updated 2020-07-01.
    # """
    local dmel url x
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
            curl --list-only --silent "${url}/current/" \
            | grep -E '^dmel_r[.0-9]+$' \
            | head -n 1 \
            | cut -d '_' -f 2 \
        )"
    else
        x="$( \
            curl --list-only --silent "${url}/" \
            | grep -E '^FB[0-9]{4}_[0-9]{2}$' \
            | sort \
            | tail -n 1 \
        )"
    fi
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::current_gencode_version() { # {{{1
    # """
    # Current GENCODE version.
    # @note Updated 2020-07-01.
    # """
    local base_url organism pattern short_name url x
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_installed curl
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
        curl --silent "$url" \
        | grep -Eo "$pattern" \
        | head -n 1 \
        | cut -d ' ' -f 2 \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::current_refseq_version() { # {{{1
    # """
    # Current RefSeq version.
    # @note Updated 2020-07-01.
    # """
    local url version
    koopa::assert_has_no_args "$#"
    url='ftp://ftp.ncbi.nlm.nih.gov/refseq/release/RELEASE_NUMBER'
    version="$(curl --silent "$url")"
    [[ -n "$version" ]] || return 1
    koopa::print "$version"
    return 0
}

koopa::current_wormbase_version() { # {{{1
    # """
    # Current WormBase version.
    # @note Updated 2020-07-01.
    # """
    local url version
    koopa::assert_has_no_args "$#"
    url="ftp://ftp.wormbase.org/pub/wormbase/\
releases/current-production-release"
    version="$( \
        curl --list-only --silent "${url}/" | \
        grep -Eo 'letter.WS[0-9]+' | \
        cut -d '.' -f 2 \
    )"
    koopa::print "$version"
    return 0
}

koopa::extract_version() { # {{{1
    # """
    # Extract version number.
    # @note Updated 2020-07-05.
    # """
    koopa::assert_has_args "$#"
    local arg pattern x
    pattern="$(koopa::version_pattern)"
    for arg in "$@"
    do
        x="$( \
            koopa::print "$arg" \
                | grep -Eo "$pattern" \
                | head -n 1 \
        )"
        [[ -n "$x" ]] || return 1
        koopa::print "$x"
    done
    return 0
}

koopa::gcc_version() { # {{{1
    # """
    # GCC version.
    # @note Updated 2020-06-29.
    # """
    local x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed gcc
    if koopa::is_macos
    then
        x="$(gcc --version 2>&1 | sed -n '2p')"
        x="$(koopa::extract_version "$x")"
    else
        x="$(koopa::return_version 'gcc')"
    fi
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
        fun="koopa::$(koopa::snake_case "$cmd")_version"
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
    # @note Updated 2020-02-15.
    #
    # @examples
    # koopa::github_latest_release 'acidgenomics/koopa'
    # # Expected failure:
    # koopa::github_latest_release 'acidgenomics/acidgenomics.github.io'
    # """
    local json repo url x
    koopa::assert_has_args "$#"
    koopa::assert_is_installed curl
    repo="${1:?}"
    url="https://api.github.com/repos/${repo}/releases/latest"
    json="$(curl -s "$url" 2>&1 || true)"
    x="$( \
        koopa::print "$json" \
            | grep '"tag_name":' \
            | cut -d '"' -f 4 \
            | sed 's/^v//' \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::hdf5_version() { # {{{1
    # """
    # HDF5 version.
    # @note Updated 2020-06-29.
    #
    # Debian: 'dpkg -s libhdf5-dev'
    # """
    local x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed h5cc
    x="$( \
        h5cc -showconfig \
            | grep 'HDF5 Version:' \
            | sed -E 's/^(.+): //' \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::llvm_version() { # {{{1
    # """
    # LLVM version.
    # @note Updated 2020-06-29.
    #
    # Note that 'llvm-config' is versioned on most systems.
    # """
    local x
    koopa::assert_has_no_args "$#"
    x="${LLVM_CONFIG:-}"
    [[ -n "$x" ]] || return 1
    x="$(koopa::return_version "$LLVM_CONFIG")"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::openjdk_version() { # {{{1
    # """
    # Java (OpenJDK) version.
    # @note Updated 2020-06-29.
    # """
    local x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed java
    x="$( \
        java --version \
            | head -n 1 \
            | cut -d ' ' -f 2 \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::oracle_instantclient_version() { # {{{1
    # """
    # Oracle InstantClient version.
    # @note Updated 2020-06-29.
    # """
    local x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed sqlplus
    x="$(sqlplus -v | grep -E '^Version')"
    x="$(koopa::extract_version "$x")"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::os_version() { # {{{1
    # """
    # Operating system version.
    # @note Updated 2020-06-29.
    #
    # 'uname' returns Darwin kernel version for macOS.
    # """
    local x
    koopa::assert_has_no_args "$#"
    if koopa::is_macos
    then
        x="$(koopa::macos_version)"
    else
        x="$(koopa::linux_version)"
    fi
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::parallel_version() { # {{{1
    # """
    # GNU parallel version.
    # @note Updated 2020-06-29.
    # """
    local x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed parallel
    x="$( \
        parallel --version \
            | head -n 1 \
            | cut -d ' ' -f 3 \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::perl_file_rename_version() { # {{{1
    # """
    # Perl File::Rename version.
    # @note Updated 2020-07-03.
    # """
    local x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed perl rename
    x="$(rename --version 2>/dev/null | head -n 1)"
    koopa::str_match "$x" 'File::Rename' || return 1
    koopa::extract_version "$x"
    return 0
}

koopa::r_package_version() { # {{{1
    # """
    # R package version.
    # @note Updated 2020-07-06.
    # """
    local r rscript vec x
    koopa::assert_has_args "$#"
    r='R'
    rscript="${r}script"
    koopa::assert_is_installed "$r" "$rscript"
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
    # @note Updated 2020-06-29.
    # """
    local r x
    r="${1:-R}"
    x="$("$r" --version 2>/dev/null | head -n 1)"
    if koopa::str_match "$x" 'R Under development (unstable)'
    then
        x='devel'
    else
        x="$(koopa::extract_version "$x")"
    fi
    koopa::print "$x"
}

koopa::return_version() { # {{{1
    # """
    # Return version (via extraction).
    # @note Updated 2020-07-14.
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
            cmd='ld'
            ;;
        coreutils)
            cmd='env'
            ;;
        findutils)
            cmd='find'
            ;;
        gdal)
            cmd='gdalinfo'
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
            cmd="$(_koopa_python)"
            ;;
        ripgrep)
            cmd='rg'
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
    # @note Updated 2020-06-29.
    #
    # We're checking the TeX Live release year here.
    # Here's what it looks like on Debian/Ubuntu:
    # TeX 3.14159265 (TeX Live 2017/Debian)
    # """
    local x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed tex
    x="$( \
        tex --version \
            | head -n 1 \
            | cut -d '(' -f 2 \
            | cut -d ')' -f 1 \
            | cut -d ' ' -f 3 \
            | cut -d '/' -f 1 \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::version() { # {{{1
    # """
    # Koopa version.
    # @note Updated 2020-06-29.
    # """
    koopa::assert_has_no_args "$#"
    koopa::variable 'koopa-version'
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
    # @note Updated 2020-11-10.
    # """
    local major_minor version x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed vim
    x="$(vim --version 2>/dev/null)"
    major_minor="$( \
        koopa::print "$x" \
            | head -n 1 \
            | cut -d ' ' -f 5 \
    )"
    # > if koopa::str_match "$x" 'Included patches:'
    # > then
    # >     local patch
    # >     patch="$( \
    # >         koopa::print "$x" \
    # >             | grep 'Included patches:' \
    # >             | cut -d '-' -f 2 \
    # >             | cut -d ',' -f 1 \
    # >     )"
    # >     version="${major_minor}.${patch}"
    # > else
    # >     version="$major_minor"
    # > fi
    version="$major_minor"
    koopa::print "$version"
    return 0
}
