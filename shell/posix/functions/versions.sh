#!/bin/sh
# shellcheck disable=SC2039

# """
# Semantic versioning
# https://semver.org/
# MAJOR.MINOR.PATCH
# """

_koopa_bcbio_nextgen_current_version() {  # {{{1
    # """
    # Get the latest bcbio-nextgen stable release version.
    # @note Updated 2020-03-26.
    #
    # This approach checks for latest stable release available via bioconda.
    # """
    _koopa_assert_is_installed curl
    local url
    url="https://raw.githubusercontent.com/bcbio/bcbio-nextgen\
/master/requirements-conda.txt"
    local x
    x="$( \
        curl --silent "$url" \
            | grep 'bcbio-nextgen=' \
            | cut -d '=' -f 2 \
    )"
    [ -n "$x" ] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_extract_version() {  # {{{1
    # """
    # Extract version number.
    # @note Updated 2020-02-10.
    # """
    local x
    x="${1:?}"
    x="$( \
        _koopa_print "$x" \
            | grep -Eo "$(_koopa_version_pattern)" \
            | head -n 1 \
    )"
    [ -n "$x" ] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_gcc_version() {  # {{{1
    # """
    # GCC version.
    # @note Updated 2020-02-10.
    # """
    _koopa_is_installed gcc || return 1
    if _koopa_is_macos
    then
        local x
        x="$(gcc --version 2>&1 | sed -n '2p')"
        _koopa_extract_version "$x"
    else
        _koopa_return_version "gcc"
    fi
    return 0
}

_koopa_get_homebrew_cask_version() {  # {{{1
    # """
    # Get Homebrew Cask version.
    # @note Updated 2020-02-12.
    #
    # @examples _koopa_get_homebrew_cask_version gpg-suite
    # # 2019.2
    # """
    local cask
    cask="${1:?}"
    local x
    x="$(brew cask info "$cask")"
    _koopa_extract_version "$x"
    return 0
}

_koopa_get_macos_app_version() {  # {{{1
    # """
    # Extract the version of a macOS application.
    # @note Updated 2020-01-12.
    # """
    _koopa_assert_is_macos
    local app
    app="${1:?}"
    local plist
    plist="/Applications/${app}.app/Contents/Info.plist"
    if [ ! -f "$plist" ]
    then
        _koopa_stop "'${app}' is not installed."
    fi
    local x
    x="$( \
        plutil -p "$plist" \
            | grep 'CFBundleShortVersionString' \
            | awk -F ' => ' '{print $2}' \
            | tr -d '\"' \
    )"
    _koopa_print "$x"
    return 0
}

_koopa_get_version() {  # {{{1
    # """
    # Get the version of an installed program.
    # @note Updated 2020-02-10.
    # """
    local cmd
    cmd="${1:?}"
    local fun
    fun="_koopa_$(_koopa_snake_case "$cmd")_version"
    if _koopa_is_function "$fun"
    then
        "$fun"
    else
        _koopa_return_version "$cmd"
    fi
    return 0
}

_koopa_github_latest_release() {  # {{{1
    # """
    # Get the latest release version from GitHub.
    # @note Updated 2020-02-15.
    #
    # @examples
    # _koopa_github_latest_release "acidgenomics/koopa"
    # # Expected failure:
    # _koopa_github_latest_release "acidgenomics/acidgenomics.github.io"
    # """
    _koopa_assert_is_installed curl
    local repo
    repo="${1:?}"
    local url
    url="https://api.github.com/repos/${repo}/releases/latest"
    local json
    json="$(curl -s "$url" 2>&1 || true)"
    local tag
    tag="$( \
        _koopa_print "$json" \
            | grep '"tag_name":' \
            | cut -d '"' -f 4 \
            | sed 's/^v//' \
    )"
    [ -n "$tag" ] || return 1
    _koopa_print "$tag"
    return 0
}

_koopa_hdf5_version() {  # {{{1
    # """
    # HDF5 version.
    # @note Updated 2020-02-07.
    #
    # Debian: 'dpkg -s libhdf5-dev'
    # """
    _koopa_is_installed h5cc || return 1
    local x
    x="$( \
        h5cc -showconfig \
            | grep 'HDF5 Version:' \
            | sed -E 's/^(.+): //' \
    )"
    [ -n "$x" ] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_linux_version() {  # {{{1
    # """
    # Linux version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_linux || return 1
    uname -r
    return 0
}

_koopa_llvm_version() {  # {{{1
    # """
    # LLVM version.
    # @note Updated 2020-02-10.
    #
    # Note that 'llvm-config' is versioned on most systems.
    # """
    [ -x "${LLVM_CONFIG:-}" ] || return 1
    _koopa_return_version "$LLVM_CONFIG"
    return 0
}

_koopa_lmod_version() {  # {{{1
    # """
    # Lmod version.
    # @note Updated 2020-02-07.
    #
    # Alterate approach:
    # > module --version 2>&1 \
    # >     | grep -Eo "Version [.0-9]+" \
    # >     | cut -d ' ' -f 2
    # """
    [ -n "${LMOD_VERSION:-}" ] || return 1
    _koopa_print "$LMOD_VERSION"
    return 0
}

_koopa_macos_version() {  # {{{1
    # """
    # macOS version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_macos || return 1
    local x
    x="$(sw_vers -productVersion)"
    _koopa_print "$x"
    return 0
}

_koopa_major_version() {  # {{{1
    # """
    # Program 'MAJOR' version.
    # @note Updated 2020-03-16.
    #
    # This function captures 'MAJOR' only, removing 'MINOR.PATCH', etc.
    # """
    local version
    version="${1:?}"
    _koopa_print "$version" | cut -d '.' -f 1
    return 0
}

_koopa_major_minor_version() {  # {{{1
    # """
    # Program 'MAJOR.MINOR' version.
    # @note Updated 2020-03-16.
    # """
    local version
    version="${1:?}"
    _koopa_print "$version" | cut -d '.' -f 1-2
    return 0
}

_koopa_major_minor_patch_version() {  # {{{1
    # """
    # Program 'MAJOR.MINOR.PATCH' version.
    # @note Updated 2020-03-16.
    # """
    local version
    version="${1:?}"
    _koopa_print "$version" | cut -d '.' -f 1-3
    return 0
}

_koopa_openjdk_version() {  # {{{1
    # """
    # Java (OpenJDK) version.
    # @note Updated 2020-06-20.
    # """
    _koopa_is_installed java || return 1
    local x
    x="$( \
        java --version \
            | head -n 1 \
            | cut -d ' ' -f 2 \
    )"
    [ -n "$x" ] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_oracle_instantclient_version() {  # {{{1
    # """
    # Oracle InstantClient version.
    # @note Updated 2020-02-10.
    # """
    _koopa_is_installed sqlplus || return 1
    local x
    x="$(sqlplus -v | grep -E '^Version')"
    _koopa_extract_version "$x"
    return 0
}

_koopa_os_version() {  # {{{1
    # """
    # Operating system version.
    # @note Updated 2020-02-08.
    #
    # 'uname' returns Darwin kernel version for macOS.
    # """
    local version
    if _koopa_is_macos
    then
        version="$(_koopa_macos_version)"
    else
        version="$(_koopa_linux_version)"
    fi
    _koopa_print "$version"
    return 0
}

_koopa_parallel_version() {  # {{{1
    # """
    # GNU parallel version.
    # @note Updated 2020-02-26.
    # """
    _koopa_is_installed parallel || return 1
    local x
    x="$( \
        parallel --version \
            | head -n 1 \
            | cut -d ' ' -f 3 \
    )"
    _koopa_print "$x"
    return 0
}

_koopa_perl_file_rename_version() {  # {{{1
    # """
    # Perl File::Rename version.
    # @note Updated 2020-02-10.
    # """
    _koopa_is_installed rename || return 1
    local x
    x="$(rename --version | head -n 1)"
    _koopa_print "$x" | grep -q 'File::Rename' || return 1
    _koopa_extract_version "$x"
    return 0
}

_koopa_return_version() {  # {{{1
    # """
    # Return version (via extraction).
    # @note Updated 2020-06-05.
    # """
    local cmd
    cmd="${1:?}"
    case "$cmd" in
        aspera-connect)
            cmd="ascp"
            ;;
        aws-cli)
            cmd="aws"
            ;;
        azure-cli)
            cmd="az"
            ;;
        bcbio-nextgen)
            cmd="bcbio_nextgen.py"
            ;;
        binutils)
            cmd="ld"
            ;;
        coreutils)
            cmd="env"
            ;;
        findutils)
            cmd="find"
            ;;
        gdal)
            cmd="gdalinfo"
            ;;
        geos)
            cmd="geos-config"
            ;;
        gnupg)
            cmd="gpg"
            ;;
        google-cloud-sdk)
            cmd="gcloud"
            ;;
        gsl)
            cmd="gsl-config"
            ;;
        homebrew)
            cmd="brew"
            ;;
        ncurses)
            cmd="ncurses6-config"
            ;;
        neovim)
            cmd="nvim"
            ;;
        pip)
            cmd="pip3"
            ;;
        python)
            cmd="python3"
            ;;
        ripgrep)
            cmd="rg"
            ;;
        rust)
            cmd="rustc"
            ;;
        sqlite)
            cmd="sqlite3"
            ;;
        subversion)
            cmd="svn"
            ;;
        texinfo)
            cmd="makeinfo"
            ;;
        the-silver-searcher)
            cmd="ag"
            ;;
    esac
    local flag
    flag="${2:-}"
    if [ -z "${flag:-}" ]
    then
        case "$cmd" in
            docker-credential-pass)
                flag="version"
                ;;
            go)
                flag="version"
                ;;
            lua)
                flag="-v"
                ;;
            openssl)
                flag="version"
                ;;
            rstudio-server)
                flag="version"
                ;;
            ssh)
                flag="-V"
                ;;
            singularity)
                flag="version"
                ;;
            tmux)
                flag="-V"
                ;;
            *)
                flag="--version"
                ;;
        esac
    fi
    _koopa_is_installed "$cmd" || return 1
    _koopa_extract_version "$("$cmd" "$flag" 2>&1 || true)"
    return 0
}

_koopa_ruby_api_version() {  # {{{1
    # """
    # Ruby API version.
    # @note Updated 2020-06-23.
    #
    # Used by Homebrew Ruby for default gem installation path.
    # See 'brew info ruby' for details.
    _koopa_is_installed ruby || return 0
    ruby -e "print Gem.ruby_api_version"
    return 0
}

_koopa_r_package_version() {  # {{{1
    # """
    # R package version.
    # @note Updated 2020-04-25.
    # """
    local pkg
    pkg="${1:?}"
    local rscript_exe
    rscript_exe="${2:-Rscript}"
    _koopa_is_installed "$rscript_exe" || return 1
    _koopa_is_r_package_installed "$pkg" "$rscript_exe" || return 1
    local x
    x="$("$rscript_exe" \
        -e "cat(as.character(packageVersion(\"${pkg}\")), \"\n\")" \
    )"
    _koopa_print "$x"
    return 0
}

_koopa_r_version() {  # {{{1
    # """
    # R version.
    # @note Updated 2020-04-25.
    # """
    local r_exe
    r_exe="${1:-R}"
    local x
    x="$("$r_exe" --version | head -n 1)"
    if _koopa_str_match "$x" 'R Under development (unstable)'
    then
        x='devel'
    else
        x="$(_koopa_extract_version "$x")"
    fi
    _koopa_print "$x"
}

_koopa_sanitize_version() {  # {{{1
    # """
    # Sanitize version.
    # @note Updated 2020-02-11.
    # """
    local x
    x="${1:?}"
    local pattern
    pattern="[.0-9]+"
    _koopa_str_match_regex "$x" "$pattern" || return 1
    x="$(_koopa_print "$x" | grep -Eo "$pattern")"
    _koopa_print "$x"
    return 0
}

_koopa_tex_version() {  # {{{1
    # """
    # TeX version.
    # @note Updated 2020-02-07.
    #
    # We're checking the TeX Live release year here.
    # Here's what it looks like on Debian/Ubuntu:
    # TeX 3.14159265 (TeX Live 2017/Debian)
    # """
    _koopa_is_installed tex || return 1
    local x
    x="$( \
        tex --version \
            | head -n 1 \
            | cut -d '(' -f 2 \
            | cut -d ')' -f 1 \
            | cut -d ' ' -f 3 \
            | cut -d '/' -f 1 \
    )"
    [ -n "$x" ] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_version() {  # {{{1
    # """
    # Koopa version.
    # @note Updated 2020-02-26.
    # """
    _koopa_variable "koopa-version"
    return 0
}

_koopa_version_pattern() {  # {{{1
    # """
    # Version pattern.
    # @note Updated 2020-02-26.
    # """
    _koopa_print '[0-9]+\.[0-9]+(\.[0-9]+)?(\.[0-9]+)?([a-z])?'
    return 0
}

_koopa_vim_version() {  # {{{1
    # """
    # Vim version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed vim || return 1
    local x
    x="$(vim --version)"
    local major
    major="$( \
        _koopa_print "$x" \
            | head -n 1 \
            | cut -d ' ' -f 5 \
    )"
    local version
    if _koopa_str_match "$x" "Included patches:"
    then
        local patch
        patch="$( \
            _koopa_print "$x" \
                | grep 'Included patches:' \
                | cut -d '-' -f 2 \
        )"
        version="${major}.${patch}"
    else
        version="$major"
    fi
    _koopa_print "$version"
    return 0
}
