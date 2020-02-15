#!/bin/sh
# shellcheck disable=SC2039

_koopa_app_prefix() {  # {{{1
    # """
    # Custom application install prefix.
    # @note Updated 2020-02-15.
    #
    # Inspired by HMS RC devops approach on O2 cluster.
    #
    # Alternatively, can consider using '/n/opt' instead of '/n/app' here.
    # """
    if [ -n "${KOOPA_APP_PREFIX:-}" ]
    then
        echo "$KOOPA_APP_PREFIX"
        return 0
    fi
    local prefix
    if _koopa_is_shared_install
    then
        if _koopa_is_macos
        then
            # Catalina doesn't allow directory creation at volume root.
            prefix="$(_koopa_make_prefix)"
        else
            # This approach allows us to save apps on a network share.
            # Particularly useful for AWS, Azure, and GCP VMs.
            prefix="/n/app"
        fi
    else
        prefix="$(_koopa_local_app_prefix)"
    fi
    echo "$prefix"
    return 0
}

_koopa_aspera_prefix() {  # {{{1
    # """
    # Aspera Connect prefix.
    # @note Updated 2020-02-06.
    # """
    local prefix
    if _koopa_is_shared_install && _koopa_has_sudo && _koopa_is_linux
    then
        prefix="$(_koopa_app_prefix)/aspera-connect"
    else
        prefix="${HOME:?}/.aspera/connect"
    fi
    echo "$prefix"
    return 0
}

_koopa_autojump_prefix() {  # {{{1
    # """
    # autojump prefix.
    # @note Updated 2020-01-12.
    # """
    local prefix
    local make_prefix
    make_prefix="$(_koopa_make_prefix)"
    # Shared installation (Linux).
    if [ -x "${make_prefix}/bin/autojump" ]
    then
        # This is the current target of cellar script.
        prefix="$make_prefix"
    elif [ -x "/usr/bin/autojump" ]
    then
        # Also support installation via package manager.
        prefix="/usr"
    else
        # Local user installation (macOS).
        prefix="${HOME:?}/.autojump"
    fi
    echo "$prefix"
    return 0
}

_koopa_bcbio_prefix() {  # {{{1
    # """
    # bcbio-nextgen prefix.
    # @note Updated 2020-01-12.
    _koopa_assert_is_linux
    local prefix
    local host_id
    host_id="$(_koopa_host_id)"
    if [ "$host_id" = "harvard-o2" ]
    then
        prefix="/n/app/bcbio/tools"
    elif [ "$host_id" = "harvard-odyssey" ]
    then
        prefix="/n/regal/hsph_bioinfo/bcbio_nextgen"
    else
        prefix="$(_koopa_app_prefix)/bcbio/stable/tools"
    fi
    echo "$prefix"
    return 0
}

_koopa_cellar_prefix() {  # {{{1
    # """
    # Cellar prefix.
    # @note Updated 2020-02-15.
    #
    # Ensure this points to a local mount (e.g. '/usr/local') instead of our
    # app dir (e.g. '/n/app'), otherwise you can run into login shell activation
    # issues on some virtual machines.
    # """
    if [ -n "${KOOPA_CELLAR_PREFIX:-}" ]
    then
        echo "$KOOPA_CELLAR_PREFIX"
        return 0
    fi
    local prefix
    if _koopa_is_installed brew
    then
        prefix="$(_koopa_make_prefix)/koopa-cellar"
    else
        prefix="$(_koopa_make_prefix)/cellar"
    fi
    echo "$prefix"
    return 0
}

_koopa_conda_prefix() {  # {{{1
    # """
    # Conda prefix
    # @note Updated 2020-01-12.
    # """
    local prefix
    if _koopa_is_installed conda
    then
        prefix="$(conda info --base)"
    else
        prefix="$(_koopa_app_prefix)/conda"
    fi
    echo "$prefix"
    return 0
}

_koopa_config_prefix() {  # {{{1
    # """
    # Local koopa config directory.
    # @note Updated 2020-01-13.
    # """
    echo "${XDG_CONFIG_HOME:-"${HOME:?}/.config"}/koopa"
    return 0
}

_koopa_docker_prefix() {  # {{{1
    # """
    # Docker prefix.
    # @note Updated 2020-02-15.
    # """
    echo "$(_koopa_config_prefix)/docker"
    return 0
}

_koopa_dotfiles_prefix() {  # {{{1
    # """
    # Koopa system dotfiles prefix.
    # @note Updated 2020-02-13.
    # """
    local prefix
    prefix="$(_koopa_prefix)/dotfiles"
    echo "$prefix"
    return 0
}

_koopa_dotfiles_private_prefix() {  # {{{1
    # """
    # Private user dotfiles prefix.
    # @note Updated 2020-02-15.
    # """
    echo "$(_koopa_config_prefix)/dotfiles-private"
    return 0
}

_koopa_ensembl_perl_api_prefix() {  # {{{1
    # """
    # Ensembl Perl API prefix.
    # @note Updated 2019-11-15.
    local prefix
    prefix="$(_koopa_app_prefix)/ensembl"
    echo "$prefix"
    return 0
}

_koopa_go_gopath() {  # {{{1
    # """
    # Go GOPATH, for building from source.
    # @note Updated 2020-02-13.
    #
    # This must be different from go root, e.g. '/n/app/go/1.13.4'.
    #
    # @seealso
    # - go help gopath
    # - go env GOPATH
    # - go env GOROOT
    # - https://golang.org/wiki/SettingGOPATH to set a custom GOPATH

    # """
    local prefix
    if [ -n "${GOPATH:-}" ]
    then
        prefix="$GOPATH"
    else
        prefix="$(_koopa_app_prefix)/go/gopath"
    fi
    echo "$prefix"
    return 0
}

_koopa_java_home() {  # {{{1
    # """
    # Java home.
    # @note Updated 2019-11-16.
    #
    # See also:
    # - https://www.mkyong.com/java/
    #       how-to-set-java_home-environment-variable-on-mac-os-x/
    # - https://stackoverflow.com/questions/22290554
    # """
    _koopa_is_installed java || return 0
    # Early return if environment variable is set.
    if [ -n "${JAVA_HOME:-}" ]
    then
        echo "$JAVA_HOME"
        return 0
    fi
    local home
    if _koopa_is_macos
    then
        home="$(/usr/libexec/java_home)"
    else
        local java_exe
        java_exe="$(_koopa_which_realpath "java")"
        home="$(dirname "$(dirname "${java_exe}")")"
    fi
    echo "$home"
    return 0
}

_koopa_local_app_prefix() {  # {{{1
    # """
    # Local user application install prefix.
    # @note Updated 2020-01-12.
    #
    # This is the default app path when koopa is installed per user.
    # """
    echo "${XDG_DATA_HOME:?}"
    return 0
}

_koopa_make_prefix() {  # {{{1
    # """
    # Return the installation prefix to use.
    # @note Updated 2020-02-15.
    # """
    if [ -n "${KOOPA_MAKE_PREFIX:-}" ]
    then
        echo "$KOOPA_MAKE_PREFIX"
        return 0
    fi
    local prefix
    if _koopa_is_shared_install && _koopa_has_sudo
    then
        prefix="/usr/local"
    else
        # This is the top-level directory of XDG_DATA_HOME.
        prefix="${HOME:?}/.local"
    fi
    echo "$prefix"
    return 0
}

_koopa_perlbrew_prefix() {  # {{{1
    # """
    # Perlbrew prefix.
    # @note Updated 2020-01-12.
    # """
    local prefix
    if [ -n "${PERLBREW_ROOT:-}" ]
    then
        prefix="$PERLBREW_ROOT"
    else
        prefix="$(_koopa_app_prefix)/perl/perlbrew"
    fi
    echo "$prefix"
    return 0
}

_koopa_prefix() {  # {{{1
    # """
    # Koopa prefix (home).
    # @note Updated 2020-01-12.
    # """
    echo "${KOOPA_PREFIX:?}"
    return 0
}

_koopa_pyenv_prefix() {  # {{{1
    # """
    # Python pyenv prefix.
    # @note Updated 2020-01-12.
    #
    # See also approach used for rbenv.
    # """
    local prefix
    prefix="$(_koopa_app_prefix)/python/pyenv"
    echo "$prefix"
    return 0
}

_koopa_python_site_packages_prefix() {
    # """
    # Python 'site-packages' library location.
    # @note Updated 2020-02-10.
    # """
    local python
    python="${1:-python3}"
    _koopa_assert_is_installed "$python"
    local x
    x="$("$python" -c "import site; print(site.getsitepackages()[0])")"
    echo "$x"
    return 0
}

_koopa_r_home() {  # {{{1
    # """
    # R home (prefix).
    # @note Updated 2020-01-21.
    # """
    if ! _koopa_is_installed R
    then
        _koopa_warning "R is not installed."
        return 1
    fi
    local home
    home="$(Rscript --vanilla -e 'cat(Sys.getenv("R_HOME"))')"
    [ -d "$home" ] || return 1
    echo "$home"
    return 0
}

_koopa_r_library_prefix() {  # {{{1
    # """
    # R default library prefix.
    # @note Updated 2020-02-10.
    # """
    _koopa_is_installed Rscript || return 1
    local prefix
    prefix="$(Rscript -e 'cat(.libPaths()[[1L]])')"
    [ -d "$prefix" ] || return 1
    echo "$prefix"
    return 0
}

_koopa_r_system_library_prefix() {  # {{{1
    # """
    # R system library prefix.
    # @note Updated 2020-02-10.
    # """
    _koopa_is_installed Rscript || return 1
    local prefix
    prefix="$(Rscript --vanilla -e 'cat(tail(.libPaths(), n = 1L))')"
    [ -d "$prefix" ] || return 1
    echo "$prefix"
    return 0
}

_koopa_rbenv_prefix() {  # {{{1
    # """
    # Ruby rbenv prefix.
    # @note Updated 2020-01-12.
    #
    # See also:
    # - RBENV_ROOT
    # - https://gist.github.com/saegey/5499096
    # """
    local prefix
    prefix="$(_koopa_app_prefix)/ruby/rbenv"
    echo "$prefix"
    return 0
}

_koopa_rust_cargo_prefix() {  # {{{1
    # """
    # Rust cargo install prefix.
    # @note Updated 2020-01-12.
    #
    # See also:
    # - https://github.com/rust-lang/rustup#environment-variables
    # - CARGO_HOME
    # - RUSTUP_HOME
    # """
    local prefix
    if _koopa_is_shared_install
    then
        prefix="$(_koopa_app_prefix)/rust/cargo"
    else
        prefix="${HOME:?}/.cargo"
    fi
    echo "$prefix"
    return 0
}

_koopa_rust_rustup_prefix() {  # {{{1
    # """
    # Rust rustup install prefix.
    # @note Updated 2020-01-13.
    # """
    local prefix
    if _koopa_is_shared_install
    then
        prefix="$(_koopa_app_prefix)/rust/rustup"
    else
        prefix="${HOME:?}/.rustup"
    fi
    echo "$prefix"
    return 0
}

_koopa_scripts_private_prefix() {  # {{{1
    # """
    # Private scripts prefix.
    # @note Updated 2020-02-15.
    # """
    echo "$(_koopa_config_prefix)/scripts-private"
    return 0
}

_koopa_venv_prefix() {  # {{{1
    # """
    # Python venv prefix.
    # @note Updated 2020-01-12.
    # """
    local prefix
    prefix="$(_koopa_app_prefix)/python/virtualenvs"
    echo "$prefix"
    return 0
}
