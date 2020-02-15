#!/bin/sh
# shellcheck disable=SC2039

# """
# Semantic versioning
# https://semver.org/
# MAJOR.MINOR.PATCH
# """

_koopa_version() {  # {{{1
    # """
    # Koopa version.
    # @note Updated 2020-02-07.
    # """
    _koopa_variable "koopa"
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
    echo "$version"
}



_koopa_major_version() {  # {{{1
    # """
    # Get the major program version.
    # @note Updated 2020-01-12.
    # """
    local version
    version="${1:?}"
    echo "$version" | cut -d '.' -f 1
}

_koopa_minor_version() {  # {{{1
    # """
    # Get the major program version.
    # @note Updated 2020-01-12.
    # """
    local version
    version="${1:?}"
    echo "$version" | cut -d '.' -f 1-2
}

_koopa_extract_version() {  # {{{1
    # """
    # Extract version number.
    # @note Updated 2020-02-10.
    # """
    local x
    x="${1:?}"
    x="$( \
        echo "$x" \
            | grep -Eo '[0-9]+\.[0-9]+(\.[0-9]+)?(\.[0-9]+)?([a-z])?' \
            | head -n 1 \
    )"
    [ -n "$x" ] || return 1
    echo "$x"
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
    _koopa_is_matching_regex "$x" "$pattern" || return 1
    x="$(echo "$x" | grep -Eo "$pattern")"
    echo "$x"
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
}

_koopa_return_version() {  # {{{1
    # """
    # Return version (via extraction).
    # @note Updated 2020-02-10.
    # """
    local cmd
    cmd="${1:?}"
    case "$cmd" in
        aws-cli)
            cmd="aws"
            ;;
        azure-cli)
            cmd="az"
            ;;
        bcbio-nextgen)
            cmd="bcbio_nextgen.py"
            ;;
        coreutils)
            cmd="env"
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
    plutil -p "$plist" \
        | grep 'CFBundleShortVersionString' \
        | awk -F ' => ' '{print $2}' \
        | tr -d '"'
}

_koopa_github_latest_release() {  # {{{1
    # """
    # Get the latest release version from GitHub.
    # @note Updated 2020-02-07.
    #
    # @examples
    # _koopa_github_latest_release "acidgenomics/koopa"
    # # Expected failure:
    # _koopa_github_latest_release "acidgenomics/acidgenomics.github.io"
    # """
    _koopa_assert_is_installed curl
    local repo
    repo="${1:?}"
    local x
    x="$(curl -s "https://github.com/${repo}/releases/latest" 2>&1)"
    x="$(echo "$x" | grep -Eo '/tag/[-_.A-Za-z0-9]+')"
    if [ -z "$x" ]
    then
        _koopa_stop "'${repo}' does not contain latest release tag."
    fi
    echo "$x" \
        | cut -d '/' -f 3 \
        | sed 's/^v//'
}

_koopa_r_package_version() {  # {{{1
    # """
    # R package version.
    # Updated 2020-02-10.
    # """
    local pkg
    pkg="${1:?}"
    _koopa_is_r_package_installed "$pkg" || return 1
    local x
    x="$(Rscript -e "cat(as.character(packageVersion(\"${pkg}\")), \"\n\")")"
    echo "$x"
}



_koopa_bcbio_nextgen_current_version() {  # {{{1
    # """
    # Get the latest bcbio-nextgen stable release version.
    # @note Updated 2020-02-10.
    #
    # Alternate approach:
    # > current="$(_koopa_github_latest_release "bcbio/bcbio-nextgen")"
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
    echo "$x"
}

_koopa_bioconductor_version() {  # {{{1
    # """
    # Bioconductor version.
    # @note Updated 2020-02-07.
    # """
    _koopa_r_package_version "BiocVersion"
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
    echo "$x"
}

_koopa_linux_version() {  # {{{1
    # """
    # Linux version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_linux || return 1
    uname -r
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
    echo "$LMOD_VERSION"
}

_koopa_macos_version() {  # {{{1
    # """
    # macOS version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_macos || return 1
    sw_vers -productVersion
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
}

_koopa_perl_file_rename_version() {  # {{{1
    # """
    # Perl File::Rename version.
    # @note Updated 2020-02-10.
    # """
    _koopa_is_installed rename || return 1
    local x
    x="$(rename --version | head -n 1)"
    echo "$x" | grep -q 'File::Rename' || return 1
    _koopa_extract_version "$x"
}

_koopa_r_version() {  # {{{1
    # """
    # R version.
    # @note Updated 2020-02-10.
    # """
    _koopa_is_installed R || return 1
    local x
    x="$(R --version | grep 'R version')"
    _koopa_extract_version "$x"
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
    echo "$x"
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
        echo "$x" \
        | head -n 1 \
        | cut -d ' ' -f 5 \
    )"
    local version
    if _koopa_is_matching_fixed "$x" "Included patches:"
    then
        local patch
        patch="$( \
            echo "$x" \
            | grep 'Included patches:' \
            | cut -d '-' -f 2 \
        )"
        version="${major}.${patch}"
    else
        version="$major"
    fi
    echo "$version"
}
