#!/bin/sh
# shellcheck disable=SC2039

# FIXME Rework the names: '_koopa_XXX_version'
# FIXME Need to convert '-' to '_', maybe '.' for names.
# FIXME Work on this in the internal koopa version functions.

_koopa_version_autojump() {
    _koopa_is_installed autojump || return 1
    autojump --version 2>&1 \
        | head -n 1 \
        | cut -d ' ' -f 2 \
        | sed 's/^v//'
}

_koopa_version_azure_cli() {
    _koopa_is_installed az || return 1
    az --version \
        | head -n 1 \
        | grep -Eo '[0-9]\.[0-9]\.[0-9]'
}

_koopa_version_bash() {
    _koopa_is_installed bash || return 1
    bash --version \
        | head -n 1 \
        | cut -d ' ' -f 4 \
        | cut -d '(' -f 1
}

_koopa_version_bcbio_nextgen() {
    _koopa_is_installed bcbio_nextgen.py || return 1
    bcbio_nextgen.py --version
}

_koopa_version_bcl2fastq() {
    _koopa_is_installed bcl2fastq || return 1
    bcl2fastq --version 2>&1 \
        | sed -n '2p' \
        | cut -d ' ' -f 2 \
        | sed 's/^v//'
}

_koopa_version_bioconductor() {
    _koopa_is_installed Rscript || return 1
    Rscript -e 'cat(as.character(packageVersion("BiocVersion")), "\n")'
}

_koopa_version_broot() {
    _koopa_is_installed broot || return 1
    broot --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_version_cargo() {
    _koopa_is_installed cargo || return 1
    cargo --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_version_clang() {
    _koopa_is_installed clang || return 1
    clang --version \
        | head -n 1 \
        | cut -d ' ' -f 4
}

_koopa_version_conda() {
    _koopa_is_installed conda || return 1
    conda --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_version_coreutils() {
    env --version \
        | head -n 1 \
        | cut -d ' ' -f 4 \
        | cut -d '(' -f 1
}

_koopa_version_docker() {
    _koopa_is_installed docker || return 1
    docker --version \
        | head -n 1 \
        | cut -d ' ' -f 3 \
        | cut -d ',' -f 1
}

_koopa_version_emacs() {
    _koopa_is_installed emacs || return 1
    emacs --version \
        | head -n 1 \
        | cut -d ' ' -f 3
}

_koopa_version_exa() {
    _koopa_is_installed exa || return 1
    exa --version \
        | head -n 1 \
        | cut -d ' ' -f 2 \
        | sed 's/^v//'
}

_koopa_version_fd() {
    _koopa_is_installed fd || return 1
    fd --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_version_fish() {
    _koopa_is_installed fish | return 1
    fish --version \
        | head -n 1 \
        | cut -d ' ' -f 3
}

_koopa_version_fzf() {
    _koopa_is_installed fzf || return 1
    fzf --version \
        | head -n 1 \
        | cut -d ' ' -f 1
}

_koopa_version_gcc() {
    _koopa_is_installed gcc || return 1
    gcc --version \
        | head -n 1 \
        | grep -Eo '[0-9]\.[0-9]\.[0-9]' \
        | head -n 1
}

# FIXME Previously labeled with darwin.
_koopa_version_gcc_macos() {
    _koopa_is_macos || return 1
    _koopa_is_installed gcc || return 1
    gcc --version 2>&1 \
        | sed -n '2p' \
        | cut -d ' ' -f 4
}

_koopa_version_gdal() {
    _koopa_is_installed gdalinfo || return 1
    gdalinfo --version \
        | head -n 1 \
        | cut -d ' ' -f 2 \
        | tr -d ','
}

_koopa_version_geos() {
    _koopa_is_installed geos-config || return 1
    geos-config --version
}

_koopa_version_git() {
    _koopa_is_installed git || return 1
    git --version \
        | head -n 1 \
        | cut -d ' ' -f 3
}

_koopa_version_gnupg() {
    _koopa_is_installed gpg || return 1
    gpg --version \
        | head -n 1 \
        | cut -d ' ' -f 3
}

_koopa_version_go() {
    _koopa_is_installed go || return 1
    go version \
        | grep -Eo "go[.0-9]+" \
        | cut -c 3-
}

_koopa_version_gsl() {
    _koopa_is_installed gsl-config || return 1
    gsl-config --version \
        | head -n 1
}

_koopa_version_hdf5() {
    # Debian: 'dpkg -s libhdf5-dev'
    _koopa_is_installed h5cc || return 1
    h5cc -showconfig \
        | grep 'HDF5 Version:' \
        | sed -E 's/^(.+): //'
}

_koopa_version_homebrew() {
    _koopa_is_installed homebrew || return 1
    brew --version 2>&1 \
        | head -n 1 \
        | cut -d ' ' -f 2 \
        | cut -d '-' -f 1
}

_koopa_version_htop() {
    _koopa_is_installed htop || return 1
    htop --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_version_java() {
    _koopa_is_installed java || return 1
    java -version 2>&1 \
        | head -n 1 \
        | cut -d ' ' -f 3 \
        | sed -e 's/\"//g'
}

_koopa_version_julia() {
    _koopa_is_installed julia || return 1
    julia --version \
        | head -n 1 \
        | cut -d ' ' -f 3
}

# FIXME This is redundant.
_koopa_version_koopa() {
    _koopa_is_installed koopa
    koopa --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_version_llvm() {
    # Note that 'llvm-config' is versioned on most systems.
    [ -x "${LLVM_CONFIG:-}" ] || return 1
    "$LLVM_CONFIG" --version
}

_koopa_lmod_version() {
    # """
    # Alterate approach:
    # > module --version 2>&1 \
    # >     | grep -Eo "Version [.0-9]+" \
    # >     | cut -d ' ' -f 2
    # """
    [ -n "${LMOD_VERSION:-}" ] || return 1
    echo "$LMOD_VERSION"
}

_koopa_version_lua() {
    _koopa_is_installed lua || return 1
    lua -v 2>&1 \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_version_luarocks() {
    _koopa_is_installed luarocks || return 1
    luarocks --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_version_macos() {
    _koopa_is_macos || return 1
    sw_vers -productVersion
}

_koopa_version_neofetch() {
    _koopa_is_installed neofetch || return 1
    neofetch --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_version_neovim() {
    _koopa_is_installed nvim || return 1
    nvim --version \
        | head -n 1 \
        | cut -d ' ' -f 2 \
        | sed 's/^v//'
}

_koopa_version_openssl() {
    _koopa_is_installed openssl || return 1
    openssl version \
        | head -n 1 \
        | cut -d ' ' -f 2 \
        | cut -d '-' -f 1
}

_koopa_version_oracle_instantclient() {
    _koopa_is_installed sqlplus || return 1
    sqlplus -v \
        | grep -E '^Version' \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_version_pandoc() {
    _koopa_is_installed pandoc || return 1
    pandoc --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_version_perl_file_rename() {
    _koopa_is_installed rename || return 1
    local x
    x="$(rename --version | head -n 1)"
    echo "$x" | grep -q 'File::Rename' || return 1
    echo "$x" | cut -d ' ' -f 5
}

_koopa_version_perl() {
    _koopa_is_installed perl || return 1
    perl --version \
        | sed -n '2p' \
        | grep -Eo "v[.0-9]+" \
        | sed 's/^v//'
}

_koopa_version_perlbrew() {
    _koopa_is_installed perlbrew || return 1
    perlbrew --version \
        | head -n 1 \
        | cut -d '-' -f 2 \
        | cut -d '/' -f 2
}

_koopa_version_pip() {
    _koopa_is_installed pip3 || return 1
    pip3 --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_version_pipx() {
    _koopa_is_installed pipx || return 1
    pipx --version \
        | head -n 1
}

_koopa_version_proj() {
    _koopa_is_installed proj || return 1
    proj 2>&1 \
        | head -n 1 \
        | cut -d ' ' -f 2 \
        | tr -d ','
}

_koopa_version_pyenv() {
    _koopa_is_installed pyenv || return 1
    pyenv --version \
        | head -n 1 \
        | cut -d ' ' -f 2 \
        | cut -d '-' -f 1
}

_koopa_version_python() {
    _koopa_is_installed python3 || return 1
    python3 --version 2>&1 \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_version_r() {
    _koopa_is_installed R || return 1
    R --version \
        | grep 'R version' \
        | cut -d ' ' -f 3
}

_koopa_version_r_basejump() {
    _koopa_is_installed Rscript || return 1
    Rscript -e 'cat(as.character(packageVersion("basejump")), "\n")'
}

_koopa_version_rbenv() {
    _koopa_is_installed rbenv || return 1
    rbenv --version \
        | head -n 1 \
        | cut -d ' ' -f 2 \
        | cut -d '-' -f 1
}

_koopa_version_ripgrep() {
    _koopa_is_installed rg || return 1
    rg --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_version_rmate() {
    _koopa_is_installed rmate || return 1
    rmate --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_version_rstudio_server() {
    # """
    # Note that final step removes '-N' patch, which only applies to
    # RStudio Server Pro release version.
    # """
    _koopa_is_installed rstudio-server || return 1
    rstudio-server version \
        | head -n 1 \
        | cut -d ' ' -f 1 \
        | cut -d '-' -f 1
}

_koopa_version_ruby() {
    _koopa_is_installed ruby || return 1
    ruby --version \
        | head -n 1 \
        | cut -d ' ' -f 2 \
        | cut -d 'p' -f 1
}

_koopa_version_rust() {
    _koopa_is_installed rustc || return 1
    rustc --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_version_rustup() {
    _koopa_is_installed rustup || return 1
    rustup --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_version_shellcheck() {
    _koopa_is_installed shellcheck || return 1
    shellcheck --version \
        | sed -n '2p' \
        | cut -d ' ' -f 2
}

_koopa_version_shiny_server() {
    _koopa_is_installed shiny-server || return 1
    shiny-server --version \
        | head -n 1 \
        | cut -d ' ' -f 3 \
        | sed 's/^v//'
}

_koopa_version_singularity() {
    _koopa_is_installed singularity || return 1
    singularity version
}

_koopa_version_sqlite() {
    _koopa_is_installed sqlite3 || return 1
    sqlite3 --version \
        | head -n 1 \
        | cut -d ' ' -f 1
}

_koopa_version_tex() {
    # """
    # Note that we're checking the TeX Live release year here.
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

_koopa_version_the_silver_searcher() {
    _koopa_is_installed ag || return 1
    ag --version \
        | head -n 1 \
        | cut -d ' ' -f 3
}

_koopa_version_tmux() {
    _koopa_is_installed tmux || return 1
    tmux -V \
        | head -n 1 \
        | cut -d ' ' -f 2
}

_koopa_version_vim() {
    _koopa_is_installed vim || return 1
    local major
    major="$( \
        vim --version \
        | head -n 1 \
        | cut -d ' ' -f 5 \
    )"
    local patch
    patch="$( \
        vim --version \
        | grep 'Included patches:' \
        | cut -d '-' -f 2 \
    )"
    local version
    if [ -n "$patch" ]
    then
        version="${major}.${patch}"
    else
        version="${major}"
    fi
    echo "$version"
}

_koopa_version_zsh() {
    _koopa_is_installed zsh || return 1
    zsh --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}
