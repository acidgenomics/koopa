#!/usr/bin/env bash

koopa::install_autoconf() {
    koopa::install_cellar --name='autoconf' "$@"
    return 0
}

koopa::install_autojump() {
    koopa::install_cellar --name='autojump' "$@"
    return 0
}

koopa::install_automake() {
    koopa::install_cellar --name="automake" "$@"
    return 0
}

koopa::install_aws_cli() {
    koopa::install_cellar \
        --name="aws-cli" \
        --name-fancy="AWS CLI" \
        --version="latest" \
        --include-dirs="bin" \
        "$@"
    return 0
}

koopa::install_bash() {
    koopa::install_cellar --name="bash" --name-fancy="Bash" "$@"
    return 0
}

koopa::install_binutils() {
    koopa::install_cellar --name="binutils" "$@"
    return 0
}

koopa::install_cmake() {
    koopa::install_cellar --name="cmake" --name-fancy="CMake" "$@"
    return 0
}

koopa::install_coreutils() {
    koopa::install_cellar --name="coreutils" "$@"
    return 0
}

koopa::install_curl() {
    koopa::install_cellar --name="curl" --name-fancy="cURL" "$@"
    return 0
}

koopa::install_docker_credential_pass() {
    koopa::install_cellar --name="docker-credential-pass" "$@"
    return 0
}

koopa::install_emacs() {
    koopa::install_cellar --name="emacs" --name-fancy="Emacs" "$@"
    return 0
}

koopa::install_findutils() {
    koopa::install_cellar --name="findutils" "$@"
    return 0
}

koopa::install_fish() {
    koopa::install_cellar --name="fish" --name-fancy="Fish" "$@"
    return 0
}

koopa::install_gawk() {
    koopa::install_cellar --name="gawk" --name-fancy="GNU awk" "$@"
    return 0
}

koopa::install_gcc() {
    koopa::install_cellar --name="gcc" --name-fancy="GCC" "$@"
    return 0
}

koopa::install_gdal() {
    koopa::install_cellar --name="gdal" --name-fancy="GDAL" "$@"
    return 0
}

koopa::install_geos() {
    koopa::install_cellar --name="geos" --name-fancy="GEOS"
    return 0
}

koopa::install_git() {
    koopa::install_cellar --name="git" --name-fancy="Git" "$@"
    return 0
}

koopa::install_gnupg() {
    koopa::install_cellar --name="gnupg" --name-fancy="GnuPG suite" "$@"
    if koopa::is_installed gpg-agent
    then
        gpgconf --kill gpg-agent
    fi
    return 0
}

koopa::install_grep() {
    koopa::install_cellar --name="grep" "$@"
    return 0
}

koopa::install_gsl() {
    koopa::install_cellar --name="gsl" --name-fancy="GSL" "$@"
    return 0
}

koopa::install_hdf5() {
    koopa::install_cellar --name="hdf5" --name-fancy="HDF5" "$@"
    return 0
}

koopa::install_htop() {
    koopa::install_cellar --name="htop" "$@"
    return 0
}

koopa::install_julia() {
    local install_type pos
    install_type="binary"
    pos=()
    while (("$#"))
    do
        case "$1" in
            --binary)
                install_type="binary"
                shift 1
                ;;
            --source)
                install_type="source"
                shift 1
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::install_cellar \
        --name="julia" \
        --name-fancy="Julia" \
        --script-name="julia-${install_type}" \
        "$@"
    return 0
}

koopa::install_libtool() {
    koopa::install_cellar --name="libtool" "$@"
    return 0
}

koopa::install_lua() {
    koopa::install_cellar --name="lua" --name-fancy="Lua" "$@"
    return 0
}

koopa::install_luarocks() {
    koopa::install_cellar --name="luarocks" "$@"
    return 0
}

koopa::install_make() {
    koopa::install_cellar --name="make" "$@"
    return 0
}

koopa::install_ncurses() {
    koopa::install_cellar --name="ncurses" "$@"
    return 0
}

koopa::install_neofetch() {
    koopa::install_cellar --name="neofetch" "$@"
    return 0
}

koopa::install_neovim() {
    koopa::install_cellar --name="neovim" "$@"
    return 0
}

koopa::install_openssh() {
    koopa::install_cellar --name="openssh" --name-fancy="OpenSSH" "$@"
    return 0
}

koopa::install_openssl() {
    koopa::install_cellar \
        --name="openssl" \
        --name-fancy="OpenSSL" \
        --cellar-only \
        "$@"
    return 0
}

koopa::install_parallel() {
    koopa::install_cellar --name="parallel" "$@"
    return 0
}

koopa::install_password_store() {
    # """
    # https://www.passwordstore.org/
    # https://git.zx2c4.com/password-store/
    # """
    koopa::install_cellar --name="password-store" "$@"
    return 0
}

koopa::install_patch() {
    koopa::install_cellar --name="patch" "$@"
    return 0
}

koopa::install_perl() {
    koopa::install_cellar --name="perl" --name-fancy="Perl" "$@"
    return 0
}

koopa::install_pkg_config() {
    koopa::install_cellar --name="pkg-config" "$@"
    return 0
}

koopa::install_proj() {
    koopa::install_cellar --name="proj" --name-fancy="PROJ" "$@"
    return 0
}

koopa::install_pyenv() {
    koopa::install_cellar --name="pyenv" "$@"
    return 0
}

koopa::install_python() {
    koopa::install_cellar --name="python" --name-fancy="Python" "$@"
    return 0
}

koopa::install_r() {
    koopa::install_cellar --name="r" --name-fancy="R" "$@"
    return 0
}

koopa::install_rbenv() {
    koopa::install_cellar --name="rbenv" "$@"
    return 0
}

koopa::install_rmate() {
    koopa::install_cellar --name="rmate" "$@"
    return 0
}

koopa::install_rsync() {
    koopa::install_cellar --name="rsync" "$@"
    return 0
}

koopa::install_ruby() {
    koopa::install_cellar --name='ruby' --name-fancy='Ruby'
    return 0
}

koopa::install_sed() {
    koopa::install_cellar --name="sed" "$@"
    return 0
}

koopa::install_shellcheck() {
    koopa::install_cellar --name="shellcheck" --name-fancy="ShellCheck" "$@"
    return 0
}

koopa::install_shunit2() {
    koopa::install_cellar --name="shunit2" --name-fancy="shUnit2" "$@"
    return 0
}

koopa::install_singularity() {
    koopa::install_cellar --name='singularity' "$@"
    return 0
}

koopa::install_sqlite() {
    koopa::install_cellar --name="sqlite" --name-fancy="SQLite" "$@"
    koopa::note "Reinstall PROJ and GDAL, if applicable."
    return 0
}

koopa::install_subversion() {
    koopa::install_cellar --name="subversion" "$@"
    return 0
}

koopa::install_texinfo() {
    koopa::install_cellar --name="texinfo" "$@"
    return 0
}

koopa::install_udunits() {
    koopa::install_cellar --name="udunits" "$@"
    return 0
}

koopa::install_vim() {
    koopa::install_cellar --name="vim" --name-fancy="Vim" "$@"
    return 0
}

koopa::install_wget() {
    koopa::install_cellar --name="wget" "$@"
    return 0
}

koopa::install_zsh() {
    koopa::install_cellar --name="zsh" --name-fancy="Zsh" "$@"
    koopa::fix_zsh_permissions
    return 0
}
