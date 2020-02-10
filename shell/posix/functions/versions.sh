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
    # Updated 2020-02-08.
    #
    # Note that uname returns Darwin kernel version for macOS.
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
    # Updated 2020-02-07.
    # """
    local app
    app="${1:?}"
    local fun
    fun="$(_koopa_snake_case "_koopa_${app}_version")"
    _koopa_assert_is_function "$fun"
    "$fun"
}

_koopa_get_macos_app_version() {                                          # {{{1
    # """
    # Extract the version of a macOS application.
    # Updated 2020-01-12.
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
    #
    # Expected failure:
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



_koopa_major_version() {                                                  # {{{1
    # """
    # Get the major program version.
    # Updated 2020-01-12.
    # """
    local version
    version="${1:?}"
    echo "$version" | cut -d '.' -f 1
}

_koopa_minor_version() {                                                  # {{{1
    # """
    # Get the major program version.
    # Updated 2020-01-12.
    # """
    local version
    version="${1:?}"
    echo "$version" | cut -d '.' -f 1-2
}



_koopa_autojump_version() {                                               # {{{1
    # """
    # Autojump version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed autojump || return 1
    local x
    x="$(autojump --version 2>&1 || true)"
    x="$( \
        echo "$x" \
            | head -n 1 \
            | cut -d ' ' -f 2 \
            | sed 's/^v//' \
            | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' \
    )"
    echo "$x"
}

_koopa_azure_cli_version() {                                              # {{{1
    # """
    # Azure CLI version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed az || return 1
    az --version \
        | head -n 1 \
        | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+'
}

_koopa_bash_version() {                                                   # {{{1
    # """
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed bash || return 1
    bash --version \
        | head -n 1 \
        | cut -d ' ' -f 4 \
        | cut -d '(' -f 1
}

_koopa_bcbio_nextgen_version() {                                          # {{{1
    # """
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed bcbio_nextgen.py || return 1
    bcbio_nextgen.py --version
}

_koopa_bcbio_nextgen_current_version() {                                  # {{{1
    # """
    # Get the latest bcbio-nextgen stable release version.
    # @note Updated 2020-02-07.
    #
    # Alternate approach:
    # > current="$(_koopa_github_latest_release "bcbio/bcbio-nextgen")"
    # """
    _koopa_assert_is_installed curl
    local url
    url="https://raw.githubusercontent.com/bcbio/bcbio-nextgen\
/master/requirements-conda.txt"
    curl --silent "$url" \
        | grep 'bcbio-nextgen=' \
        | cut -d '=' -f 2
}

_koopa_bcl2fastq_version() {                                              # {{{1
    # """
    # bcl2fastq version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed bcl2fastq || return 1
    bcl2fastq --version 2>&1 \
        | sed -n '2p' \
        | cut -d ' ' -f 2 \
        | sed 's/^v//'
}

_koopa_bioconductor_version() {                                           # {{{1
    # """
    # Bioconductor version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_r_package_installed BiocVersion || return 1
    Rscript -e 'cat(as.character(packageVersion("BiocVersion")), "\n")'
}

_koopa_broot_version() {                                                  # {{{1
    # """
    # Broot version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed broot || return 1
    broot --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_cargo_version() {                                                  # {{{1
    # """
    # Cargo version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed cargo || return 1
    cargo --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_clang_version() {                                                  # {{{1
    # """
    # Clang compiler version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed clang || return 1
    clang --version \
        | head -n 1 \
        | cut -d ' ' -f 4
}

_koopa_conda_version() {                                                  # {{{1
    # """
    # Conda version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed conda || return 1
    conda --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_coreutils_version() {                                              # {{{1
    # """
    # GNU coreutils version.
    # @note Updated 2020-02-07.
    # """
    env --version \
        | head -n 1 \
        | cut -d ' ' -f 4 \
        | cut -d '(' -f 1
}

_koopa_docker_version() {                                                 # {{{1
    # """
    # Docker version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed docker || return 1
    docker --version \
        | head -n 1 \
        | cut -d ' ' -f 3 \
        | cut -d ',' -f 1
}

_koopa_emacs_version() {                                                  # {{{1
    # """
    # Emacs version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed emacs || return 1
    emacs --version \
        | head -n 1 \
        | cut -d ' ' -f 3
}

_koopa_exa_version() {                                                    # {{{1
    # """
    # Exa version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed exa || return 1
    exa --version \
        | head -n 1 \
        | cut -d ' ' -f 2 \
        | sed 's/^v//'
}

_koopa_fd_version() {                                                     # {{{1
    # """
    # fd version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed fd || return 1
    fd --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_fish_version() {                                                   # {{{1
    # """
    # Fish version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed fish || return 1
    fish --version 2>&1 \
        | head -n 1 \
        | cut -d ' ' -f 3
}

_koopa_fzf_version() {                                                    # {{{1
    # """
    # fzf version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed fzf || return 1
    fzf --version \
        | head -n 1 \
        | cut -d ' ' -f 1
}

_koopa_gcc_version() {                                                    # {{{1
    # """
    # GCC version.
    # @note Updated 2020-02-08.
    # """
    _koopa_is_installed gcc || return 1
    if _koopa_is_macos
    then
        gcc --version 2>&1 \
            | sed -n '2p' \
            | cut -d ' ' -f 4
    else
        gcc --version \
            | head -n 1 \
            | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' \
            | head -n 1
    fi
}

_koopa_gdal_version() {                                                   # {{{1
    # """
    # GDAL version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed gdalinfo || return 1
    gdalinfo --version \
        | head -n 1 \
        | cut -d ' ' -f 2 \
        | tr -d ','
}

_koopa_geos_version() {                                                   # {{{1
    # """
    # GEOS version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed geos-config || return 1
    geos-config --version
}

_koopa_git_version() {                                                    # {{{1
    # """
    # Git version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed git || return 1
    git --version \
        | head -n 1 \
        | cut -d ' ' -f 3
}

_koopa_gnupg_version() {                                                  # {{{1
    # """
    # GnuPG version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed gpg || return 1
    gpg --version \
        | head -n 1 \
        | cut -d ' ' -f 3
}

_koopa_go_version() {                                                     # {{{1
    # """
    # Go version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed go || return 1
    go version \
        | grep -Eo "go[.0-9]+" \
        | cut -c 3-
}

_koopa_gsl_version() {                                                    # {{{1
    # """
    # GSL version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed gsl-config || return 1
    gsl-config --version \
        | head -n 1
}

_koopa_hdf5_version() {                                                   # {{{1
    # """
    # HDF5 version.
    # @note Updated 2020-02-07.
    #
    # Debian: 'dpkg -s libhdf5-dev'
    # """
    _koopa_is_installed h5cc || return 1
    h5cc -showconfig \
        | grep 'HDF5 Version:' \
        | sed -E 's/^(.+): //'
}

_koopa_homebrew_version() {                                               # {{{1
    # """
    # Homebrew version.
    # @note Updated 2020-02-08.
    # """
    _koopa_is_installed brew || return 1
    local x
    x="$(brew --version 2>&1 || true)"
    echo "$x" \
        | head -n 1 \
        | cut -d ' ' -f 2 \
        | cut -d '-' -f 1
}

_koopa_htop_version() {                                                   # {{{1
    # """
    # htop version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed htop || return 1
    htop --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_java_version() {                                                   # {{{1
    # """
    # Java version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed java || return 1
    java -version 2>&1 \
        | head -n 1 \
        | cut -d ' ' -f 3 \
        | sed -e 's/\"//g'
}

_koopa_julia_version() {                                                  # {{{1
    # """
    # Julia version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed julia || return 1
    julia --version \
        | head -n 1 \
        | cut -d ' ' -f 3
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
    # @note Updated 2020-02-07.
    #
    # Note that 'llvm-config' is versioned on most systems.
    # """
    [ -x "${LLVM_CONFIG:-}" ] || return 1
    "$LLVM_CONFIG" --version
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

_koopa_lua_version() {                                                    # {{{1
    # """
    # Lua version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed lua || return 1
    lua -v 2>&1 \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_luarocks_version() {                                               # {{{1
    # """
    # Luarocks version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed luarocks || return 1
    luarocks --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_macos_version() {                                                  # {{{1
    # """
    # macOS version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_macos || return 1
    sw_vers -productVersion
}

_koopa_neofetch_version() {                                               # {{{1
    # """
    # Neofetch version.
    # @note Updated 2020-02-07.
    #
    # Neofetch currently exits with an error code, which is weird.
    # - https://github.com/dylanaraps/neofetch/blob/master/neofetch#L5071
    # - https://stackoverflow.com/questions/11231937/
    #       bash-ignoring-error-for-a-particular-command
    # """
    _koopa_is_installed neofetch || return 1
    local x
    x="$(neofetch --version || true)"
    echo "$x" \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_neovim_version() {                                                 # {{{1
    # """
    # Neovim version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed nvim || return 1
    nvim --version \
        | head -n 1 \
        | cut -d ' ' -f 2 \
        | sed 's/^v//'
}

_koopa_openssl_version() {                                                # {{{1
    # """
    # OpenSSL version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed openssl || return 1
    openssl version \
        | head -n 1 \
        | cut -d ' ' -f 2 \
        | cut -d '-' -f 1
}

_koopa_oracle_instantclient_version() {                                   # {{{1
    # """
    # Oracle InstantClient version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed sqlplus || return 1
    sqlplus -v \
        | grep -E '^Version' \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_pandoc_version() {                                                 # {{{1
    # """
    # Pandoc version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed pandoc || return 1
    pandoc --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_perl_file_rename_version() {                                       # {{{1
    # """
    # Perl File::Rename version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed rename || return 1
    local x
    x="$(rename --version | head -n 1)"
    echo "$x" | grep -q 'File::Rename' || return 1
    echo "$x" | cut -d ' ' -f 5
}

_koopa_perl_version() {                                                   # {{{1
    # """
    # Perl version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed perl || return 1
    perl --version \
        | sed -n '2p' \
        | grep -Eo "v[.0-9]+" \
        | sed 's/^v//'
}

_koopa_perlbrew_version() {                                               # {{{1
    # """
    # Perlbrew version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed perlbrew || return 1
    perlbrew --version \
        | head -n 1 \
        | cut -d '-' -f 2 \
        | cut -d '/' -f 2
}

_koopa_pip_version() {                                                    # {{{1
    # """
    # pip version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed pip3 || return 1
    pip3 --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_pipx_version() {                                                   # {{{1
    # """
    # pipx version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed pipx || return 1
    pipx --version \
        | head -n 1
}

_koopa_proj_version() {                                                   # {{{1
    # """
    # PROJ version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed proj || return 1
    proj 2>&1 \
        | head -n 1 \
        | cut -d ' ' -f 2 \
        | tr -d ','
}

_koopa_pyenv_version() {                                                  # {{{1
    # """
    # pyenv version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed pyenv || return 1
    pyenv --version \
        | head -n 1 \
        | cut -d ' ' -f 2 \
        | cut -d '-' -f 1
}

_koopa_python_version() {                                                 # {{{1
    # """
    # Python version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed python3 || return 1
    python3 --version 2>&1 \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_r_version() {                                                      # {{{1
    # """
    # R version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed R || return 1
    R --version \
        | grep 'R version' \
        | cut -d ' ' -f 3
}

_koopa_r_basejump_version() {                                             # {{{1
    # """
    # basejump version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_r_package_installed basejump || return 1
    Rscript -e 'cat(as.character(packageVersion("basejump")), "\n")'
}

_koopa_rbenv_version() {                                                  # {{{1
    # """
    # rbenv version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed rbenv || return 1
    rbenv --version \
        | head -n 1 \
        | cut -d ' ' -f 2 \
        | cut -d '-' -f 1
}

_koopa_ripgrep_version() {                                                # {{{1
    # """
    # ripgrep version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed rg || return 1
    rg --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_rmate_version() {                                                  # {{{1
    # """
    # rmate version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed rmate || return 1
    rmate --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_rstudio_server_version() {                                         # {{{1
    # """
    # RStudio Server version.
    # @note Updated 2020-02-07.
    #
    # Note that final step removes '-N' patch, which only applies to
    # RStudio Server Pro release version.
    # """
    _koopa_is_installed rstudio-server || return 1
    rstudio-server version \
        | head -n 1 \
        | cut -d ' ' -f 1 \
        | cut -d '-' -f 1
}

_koopa_ruby_version() {                                                   # {{{1
    # """
    # Ruby version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed ruby || return 1
    ruby --version \
        | head -n 1 \
        | cut -d ' ' -f 2 \
        | cut -d 'p' -f 1
}

_koopa_rust_version() {                                                   # {{{1
    # """
    # Rust version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed rustc || return 1
    rustc --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_rustup_version() {                                                 # {{{1
    # """
    # rustup version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed rustup || return 1
    rustup --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_shellcheck_version() {                                             # {{{1
    # """
    # ShellCheck version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed shellcheck || return 1
    shellcheck --version \
        | sed -n '2p' \
        | cut -d ' ' -f 2
}

_koopa_shiny_server_version() {                                           # {{{1
    # """
    # Shiny Server version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed shiny-server || return 1
    shiny-server --version \
        | head -n 1 \
        | cut -d ' ' -f 3 \
        | sed 's/^v//'
}

_koopa_singularity_version() {                                            # {{{1
    # """
    # Singularity version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed singularity || return 1
    singularity version
}

_koopa_sqlite_version() {                                                 # {{{1
    # """
    # SQLite version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed sqlite3 || return 1
    sqlite3 --version \
        | head -n 1 \
        | cut -d ' ' -f 1
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
    tex --version \
        | head -n 1 \
        | cut -d '(' -f 2 \
        | cut -d ')' -f 1 \
        | cut -d ' ' -f 3 \
        | cut -d '/' -f 1
}

_koopa_the_silver_searcher_version() {                                    # {{{1
    # """
    # The Silver Searcher (Ag) version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed ag || return 1
    ag --version \
        | head -n 1 \
        | cut -d ' ' -f 3
}

_koopa_tmux_version() {                                                   # {{{1
    # """
    # Tmux version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed tmux || return 1
    tmux -V \
        | head -n 1 \
        | cut -d ' ' -f 2
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

_koopa_zsh_version() {                                                    # {{{1
    # """
    # Zsh version.
    # @note Updated 2020-02-07.
    # """
    _koopa_is_installed zsh || return 1
    zsh --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}
