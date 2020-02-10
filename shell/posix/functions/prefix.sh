#!/bin/sh
# shellcheck disable=SC2039

_koopa_prefix() {                                                         # {{{1
    # """
    # Koopa prefix (home).
    # Updated 2020-01-12.
    # """
    echo "${KOOPA_PREFIX:?}"
}

_koopa_app_prefix() {                                                     # {{{1
    # """
    # Custom application install prefix.
    # Updated 2020-01-12.
    #
    # Inspired by HMS RC devops approach on O2 cluster.
    #
    # Alternatively, can consider using '/n/opt' instead of '/n/app' here.
    # """
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
}

_koopa_cellar_prefix() {                                                  # {{{1
    # """
    # Cellar prefix.
    # Updated 2020-02-08.
    #
    # Ensure this points to a local mount (e.g. '/usr/local') instead of our
    # app dir (e.g. '/n/app'), otherwise you can run into login shell activation
    # issues on some virtual machines.
    # """
    local prefix
    if _koopa_is_installed brew
    then
        prefix="$(_koopa_make_prefix)/koopa-cellar"
    else
        prefix="$(_koopa_make_prefix)/cellar"
    fi
    echo "$prefix"
}

_koopa_config_prefix() {                                                  # {{{1
    # """
    # Local koopa config directory.
    # Updated 2020-01-13.
    # """
    echo "${XDG_CONFIG_HOME:-"${HOME:?}/.config"}/koopa"
}

_koopa_local_app_prefix() {                                               # {{{1
    # """
    # Local user application install prefix.
    # Updated 2020-01-12.
    #
    # This is the default app path when koopa is installed per user.
    # """
    echo "${XDG_DATA_HOME:?}"
}

_koopa_make_prefix() {                                                    # {{{1
    # """
    # Return the installation prefix to use.
    # Updated 2020-01-12.
    # """
    local prefix
    if _koopa_is_shared_install && _koopa_has_sudo
    then
        prefix="/usr/local"
    else
        # This is the top-level directory of XDG_DATA_HOME.
        prefix="${HOME:?}/.local"
    fi
    echo "$prefix"
}



_koopa_aspera_prefix() {                                                  # {{{1
    # """
    # Aspera Connect prefix.
    # Updated 2020-02-06.
    # """
    local prefix
    if _koopa_is_shared_install && _koopa_has_sudo && _koopa_is_linux
    then
        prefix="$(_koopa_app_prefix)/aspera-connect"
    else
        prefix="${HOME:?}/.aspera/connect"
    fi
    echo "$prefix"
}

_koopa_autojump_prefix() {                                                # {{{1
    # """
    # autojump prefix.
    # Updated 2020-01-12.
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
}

_koopa_bcbio_prefix() {                                                   # {{{1
    # """
    # bcbio-nextgen prefix.
    # Updated 2020-01-12.
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
}

_koopa_conda_prefix() {                                                   # {{{1
    # """
    # Conda prefix
    # Updated 2020-01-12.
    # """
    local prefix
    if _koopa_is_installed conda
    then
        prefix="$(conda info --base)"
    else
        prefix="$(_koopa_app_prefix)/conda"
    fi
    echo "$prefix"
}

_koopa_ensembl_perl_api_prefix() {                                        # {{{1
    # """
    # Ensembl Perl API prefix.
    # Updated 2019-11-15.
    local prefix
    prefix="$(_koopa_app_prefix)/ensembl"
    echo "$prefix"
}

_koopa_java_home() {                                                      # {{{1
    # """
    # Java home.
    # Updated 2019-11-16.
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
}

_koopa_perlbrew_prefix() {                                                # {{{1
    # """
    # Perlbrew prefix.
    # Updated 2020-01-12.
    # """
    local prefix
    if [ -n "${PERLBREW_ROOT:-}" ]
    then
        prefix="$PERLBREW_ROOT"
    else
        prefix="$(_koopa_app_prefix)/perl/perlbrew"
    fi
    echo "$prefix"
}

_koopa_pyenv_prefix() {                                                   # {{{1
    # """
    # Python pyenv prefix.
    # Updated 2020-01-12.
    #
    # See also approach used for rbenv.
    # """
    local prefix
    prefix="$(_koopa_app_prefix)/python/pyenv"
    echo "$prefix"
}

_koopa_python_site_packages_prefix() {
    # """
    # Python 'site-packages' library location.
    # Updated 2020-02-10.
    # """
    _koopa_assert_is_installed python3
    local x
    x="$(python3 -c "import site; print(site.getsitepackages()[0])")"
    echo "$x"
}

_koopa_r_home() {                                                         # {{{1
    # """
    # R home (prefix).
    # Updated 2020-01-21.
    # """
    if ! _koopa_is_installed R
    then
        _koopa_warning "R is not installed."
        return 1
    fi
    local home
    home="$(Rscript --vanilla -e 'cat(Sys.getenv("R_HOME"))')"
    echo "$home"
}

_koopa_r_library_prefix() {                                               # {{{1
    # """
    # R default library prefix.
    # Updated 2020-02-05.
    # """
    local prefix
    prefix="$(Rscript -e '.libPaths()[[1L]]')"
    echo "$prefix"
}

_koopa_r_system_library_prefix() {                                        # {{{1
    # """
    # R system library prefix.
    # Updated 2020-02-05.
    # """
    local prefix
    prefix="$(Rscript --vanilla -e 'tail(.libPaths(), n = 1L)')"
    echo "$prefix"
}

_koopa_rbenv_prefix() {                                                   # {{{1
    # """
    # Ruby rbenv prefix.
    # Updated 2020-01-12.
    #
    # See also:
    # - RBENV_ROOT
    # - https://gist.github.com/saegey/5499096
    # """
    local prefix
    prefix="$(_koopa_app_prefix)/ruby/rbenv"
    echo "$prefix"
}

_koopa_rust_cargo_prefix() {                                              # {{{1
    # """
    # Rust cargo install prefix.
    # Updated 2020-01-12.
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
}

_koopa_rust_rustup_prefix() {                                             # {{{1
    # """
    # Rust rustup install prefix.
    # Updated 2020-01-13.
    # """
    local prefix
    if _koopa_is_shared_install
    then
        prefix="$(_koopa_app_prefix)/rust/rustup"
    else
        prefix="${HOME:?}/.rustup"
    fi
    echo "$prefix"
}

_koopa_venv_prefix() {                                                    # {{{1
    # """
    # Python venv prefix.
    # Updated 2020-01-12.
    # """
    local prefix
    prefix="$(_koopa_app_prefix)/python/virtualenvs"
    echo "$prefix"
}
