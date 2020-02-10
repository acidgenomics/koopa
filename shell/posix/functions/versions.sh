#!/bin/sh
# shellcheck disable=SC2039

# """
# Semantic versioning
# https://semver.org/
# MAJOR.MINOR.PATCH
# """

_koopa_version() {                                                        # {{{1
    # """
    # Koopa version.
    # @note Updated 2020-02-07.
    # """
    _koopa_variable "koopa"
}

_koopa_os_version() {                                                     # {{{1
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



_koopa_get_version() {                                                    # {{{1
    # """
    # Get the version of an installed program.
    # @note Updated 2020-02-10.
    # """
    local cmd
    cmd="${1:?}"
    local fun
    fun="$(_koopa_snake_case "_koopa_${cmd}_version")"
    if _koopa_is_function "$fun"
    then
        "$fun"
    else
        _koopa_return_version "$cmd"
    fi
}

_koopa_get_macos_app_version() {                                          # {{{1
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

_koopa_github_latest_release() {                                          # {{{1
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

_koopa_r_package_version() {
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



_koopa_major_version() {                                                  # {{{1
    # """
    # Get the major program version.
    # @note Updated 2020-01-12.
    # """
    local version
    version="${1:?}"
    echo "$version" | cut -d '.' -f 1
}

_koopa_minor_version() {                                                  # {{{1
    # """
    # Get the major program version.
    # @note Updated 2020-01-12.
    # """
    local version
    version="${1:?}"
    echo "$version" | cut -d '.' -f 1-2
}

_koopa_extract_version() {                                                # {{{1
    # """
    # Extract version number.
    # @note Updated 2020-02-10.
    # """
    local x
    x="${1:?}"
    x="$( \
        echo "$x" \
            | grep -Eo '[0-9]+\.[0-9]+(\.[0-9]+)?' \
            | head -n 1 \
    )"
    [ -n "$x" ] || return 1
    echo "$x"
}

_koopa_return_version() {
    # """
    # Return version (via extraction).
    # @note Updated 2020-02-10.
    # """
    local cmd
    cmd="${1:?}"
    local flag
    flag="${2:-"--version"}"
    _koopa_is_installed "$cmd" || return 1
    _koopa_extract_version "$("$cmd" "$flag" 2>&1 || true)"
}



# FIXME Rename in check.
_koopa_azure_cli_version() {                                              # {{{1
    # """
    # Azure CLI version.
    # @note Updated 2020-02-10.
    # """
    _koopa_return_version "az"
}

# FIXME Rename in check.
_koopa_bcbio_nextgen_version() {                                          # {{{1
    # """
    # bcbio-nextgen version.
    # @note Updated 2020-02-10.
    # """
    _koopa_return_version "bcbio_nextgen.py"
}

_koopa_bcbio_nextgen_current_version() {                                  # {{{1
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

_koopa_bioconductor_version() {                                           # {{{1
    # """
    # Bioconductor version.
    # @note Updated 2020-02-07.
    # """
    _koopa_r_package_version "BiocVersion"
}

# FIXME Rename check.
_koopa_coreutils_version() {                                              # {{{1
    # """
    # GNU coreutils version.
    # @note Updated 2020-02-10.
    # """
    _koopa_return_version "env"
}

# FIXME Can we simplify?
_koopa_gcc_version() {                                                    # {{{1
    # """
    # GCC version.
    # @note Updated 2020-02-10.
    # """
    _koopa_is_installed gcc || return 1
    if _koopa_is_macos
    then
        gcc --version 2>&1 \
            | sed -n '2p' \
            | cut -d ' ' -f 4
    else
        _koopa_return_version "gcc"
    fi
}

# FIXME Rename the internal check
_koopa_gdal_version() {                                                   # {{{1
    # """
    # GDAL version.
    # @note Updated 2020-02-10.
    # """
    _koopa_return_version "gdalinfo"
}

# FIXME Rename the check.
_koopa_geos_version() {                                                   # {{{1
    # """
    # GEOS version.
    # @note Updated 2020-02-07.
    # """
    _koopa_return_version "geos-config"
}

# FIXME Rename the check.
_koopa_gnupg_version() {                                                  # {{{1
    # """
    # GnuPG version.
    # @note Updated 2020-02-07.
    # """
    _koopa_return_version "gpg"
}

# FIXME Rename the check.
_koopa_gsl_version() {                                                    # {{{1
    # """
    # GSL version.
    # @note Updated 2020-02-07.
    # """
    _koopa_return_version "gsl-config"
}

_koopa_hdf5_version() {                                                   # {{{1
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

# FIXME Rename the check.
_koopa_homebrew_version() {                                               # {{{1
    # """
    # Homebrew version.
    # @note Updated 2020-02-08.
    # """
    _koopa_return_version "brew"
}

_koopa_linux_version() {                                                  # {{{1
    # """
    # Linux version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_linux || return 1
    uname -r
}

_koopa_llvm_version() {                                                   # {{{1
    # """
    # LLVM version.
    # @note Updated 2020-02-10.
    #
    # Note that 'llvm-config' is versioned on most systems.
    # """
    [ -x "${LLVM_CONFIG:-}" ] || return 1
    _koopa_return_version "$LLVM_CONFIG"
}

_koopa_lmod_version() {                                                   # {{{1
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

_koopa_macos_version() {                                                  # {{{1
    # """
    # macOS version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_macos || return 1
    sw_vers -productVersion
}

# FIXME Rename the check.
_koopa_neovim_version() {                                                 # {{{1
    # """
    # Neovim version.
    # @note Updated 2020-02-07.
    # """
    _koopa_return_version "nvim"
}

_koopa_openssl_version() {                                                # {{{1
    # """
    # OpenSSL version.
    # @note Updated 2020-02-10.
    # """
    _koopa_return_version "openssl" "version"
}

_koopa_oracle_instantclient_version() {                                   # {{{1
    # """
    # Oracle InstantClient version.
    # @note Updated 2020-02-10.
    # """
    _koopa_is_installed sqlplus || return 1
    local x
    x="$(sqlplus -v | grep -E '^Version')"
    _koopa_extract_version "$x"
}

_koopa_perl_file_rename_version() {                                       # {{{1
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

# FIXME Rename this check.
_koopa_pip_version() {                                                    # {{{1
    # """
    # pip version.
    # @note Updated 2020-02-10.
    # """
    _koopa_return_version "pip3"
}

# FIXME Rename this check.
_koopa_python_version() {                                                 # {{{1
    # """
    # Python version.
    # @note Updated 2020-02-10.
    # """
    _koopa_return_version "python3"
}

_koopa_r_version() {                                                      # {{{1
    # """
    # R version.
    # @note Updated 2020-02-10.
    # """
    _koopa_is_installed R || return 1
    local x
    x="$(R --version | grep 'R version')"
    _koopa_extract_version "$x"
}

_koopa_r_basejump_version() {                                             # {{{1
    # """
    # basejump version.
    # @note Updated 2020-02-10.
    # """
    _koopa_r_package_version "basejump"
}

_koopa_rstudio_server_version() {                                         # {{{1
    # """
    # RStudio Server version.
    # @note Updated 2020-02-10.
    #
    # Note that final step removes '-N' patch, which only applies to
    # RStudio Server Pro release version.
    # """
    _koopa_return_version "rstudio-server" "version"
}

# FIXME Rename check.
_koopa_rust_version() {                                                   # {{{1
    # """
    # Rust version.
    # @note Updated 2020-02-07.
    # """
    _koopa_return_version "rustc"
}

_koopa_singularity_version() {                                            # {{{1
    # """
    # Singularity version.
    # @note Updated 2020-02-10.
    # """
    _koopa_return_version "singularity" "version"
}

# FIXME Rename this check.
_koopa_sqlite_version() {                                                 # {{{1
    # """
    # SQLite version.
    # @note Updated 2020-02-10.
    # """
    _koopa_return_version "sqlite3"
}

_koopa_tex_version() {                                                    # {{{1
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

# FIXME Rename this check.
_koopa_the_silver_searcher_version() {                                    # {{{1
    # """
    # The Silver Searcher (Ag) version.
    # @note Updated 2020-02-07.
    # """
    _koopa_return_version "ag"
}

_koopa_tmux_version() {                                                   # {{{1
    # """
    # Tmux version.
    # @note Updated 2020-02-10.
    # """
    _koopa_return_version "tmux" "-V"
}

_koopa_vim_version() {                                                    # {{{1
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
