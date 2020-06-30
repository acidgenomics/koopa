#!/bin/sh
# shellcheck disable=SC2039

_koopa_app_prefix() {  # {{{1
    # """
    # Custom application install prefix.
    # @note Updated 2020-02-16.
    # """
    local prefix
    if [ -n "${KOOPA_APP_PREFIX:-}" ]
    then
        prefix="$KOOPA_APP_PREFIX"
    elif _koopa_is_shared_install && _koopa_is_installed brew
    then
        prefix="$(_koopa_prefix)/opt"
    elif _koopa_is_shared_install
    then
        prefix="$(_koopa_make_prefix)/opt"
    else
        prefix="$(_koopa_local_app_prefix)"
    fi
    _koopa_print "$prefix"
}

_koopa_aspera_prefix() {  # {{{1
    # """
    # Aspera Connect prefix.
    # @note Updated 2020-02-16.
    # """
    local prefix
    if _koopa_is_shared_install
    then
        prefix="$(_koopa_app_prefix)/aspera-connect"
    else
        prefix="${HOME:?}/.aspera/connect"
    fi
    _koopa_print "$prefix"
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
    _koopa_print "$prefix"
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
    _koopa_print "$prefix"
}

_koopa_cellar_prefix() {  # {{{1
    # """
    # Cellar prefix.
    # @note Updated 2020-05-06.
    #
    # Currently only supported for Linux.
    # Use Homebrew on macOS instead.
    #
    # Ensure this points to a local mount (e.g. '/usr/local').
    # """
    _koopa_is_linux || return 0
    local prefix
    if [ -n "${KOOPA_CELLAR_PREFIX:-}" ]
    then
        prefix="$KOOPA_CELLAR_PREFIX"
    elif _koopa_is_shared_install && _koopa_is_installed brew
    then
        prefix="$(_koopa_prefix)/cellar"
    else
        prefix="$(_koopa_make_prefix)/cellar"
    fi
    _koopa_print "$prefix"
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
    _koopa_print "$prefix"
}

_koopa_config_prefix() {  # {{{1
    # """
    # Local koopa config directory.
    # @note Updated 2020-01-13.
    # """
    _koopa_print "${XDG_CONFIG_HOME:-"${HOME:?}/.config"}/koopa"
}

_koopa_data_disk_link_prefix() {  # {{{1
    # """
    # Data disk symlink prefix.
    # @note Updated 2020-02-16.
    # """
    _koopa_is_linux || return 1
    _koopa_print "/n"
}

_koopa_docker_prefix() {  # {{{1
    # """
    # Docker prefix.
    # @note Updated 2020-02-15.
    # """
    _koopa_print "$(_koopa_config_prefix)/docker"
}

_koopa_docker_private_prefix() {  # {{{1
    # """
    # Private Docker prefix.
    # @note Updated 2020-03-05.
    # """
    _koopa_print "$(_koopa_config_prefix)/docker-private"
}

_koopa_dotfiles_prefix() {  # {{{1
    # """
    # Koopa system dotfiles prefix.
    # @note Updated 2020-05-05.
    # """
    _koopa_print "$(_koopa_prefix)/dotfiles"
}

_koopa_dotfiles_private_prefix() {  # {{{1
    # """
    # Private user dotfiles prefix.
    # @note Updated 2020-02-15.
    # """
    _koopa_print "$(_koopa_config_prefix)/dotfiles-private"
}

_koopa_emacs_prefix() {  # {{{1
    # """
    # Default Emacs prefix.
    # @note Updated 2020-06-29.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "${HOME}/.emacs.d"
}

_koopa_ensembl_perl_api_prefix() {  # {{{1
    # """
    # Ensembl Perl API prefix.
    # @note Updated 2019-11-15.
    _koopa_print "$(_koopa_app_prefix)/ensembl"
}

_koopa_fzf_prefix() {  # {{{1
    # """
    # fzf prefix.
    # @note Updated 2020-03-16.
    # """
    _koopa_print "$(_koopa_app_prefix)/fzf"
}

_koopa_go_gopath() {  # {{{1
    # """
    # Go GOPATH, for building from source.
    # @note Updated 2020-02-13.
    #
    # This must be different from go root.
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
    _koopa_print "$prefix"
}

_koopa_homebrew_cellar_prefix() {  # {{{1
    _koopa_is_installed brew || return 1
    local x
    x="$(_koopa_homebrew_prefix)/Cellar"
    [ -d "$x" ] || return 1
    _koopa_print "$x"
}

_koopa_homebrew_prefix() {  # {{{1
    # """
    # Homebrew prefix.
    # @note Updated 2020-02-23.
    # """
    _koopa_is_installed brew || return 1
    local x
    x="${HOMEBREW_PREFIX:?}"
    [ -d "$x" ] || return 1
    _koopa_print "$x"
}

_koopa_homebrew_ruby_gems_prefix() {  # {{{1
    # """
    # Homebrew Ruby gems prefix.
    # @note Updated 2020-06-23.
    # """
    _koopa_is_installed ruby || return 0
    local homebrew_prefix
    homebrew_prefix="$(_koopa_homebrew_prefix)"
    local api_version
    api_version="$(_koopa_ruby_api_version)"
    local prefix
    prefix="${homebrew_prefix}/lib/ruby/gems/${api_version}/bin"
    _koopa_print "$prefix"
}

_koopa_include_prefix() { # {{{1
    # """
    # Koopa system includes prefix.
    # @note Updated 2020-06-24.
    # """
    _koopa_print "$(_koopa_prefix)/system/include"
}

_koopa_java_prefix() {  # {{{1
    # """
    # Java prefix.
    # @note Updated 2020-06-24.
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
        _koopa_print "$JAVA_HOME"
        return 0
    fi
    local prefix
    if _koopa_is_macos
    then
        prefix="$(/usr/libexec/java_home)"
    else
        local java_exe
        java_exe="$(_koopa_which "java")"
        prefix="$(dirname "$(dirname "${java_exe}")")"
    fi
    _koopa_print "$prefix"
}

_koopa_local_app_prefix() {  # {{{1
    # """
    # Local user application install prefix.
    # @note Updated 2020-01-12.
    #
    # This is the default app path when koopa is installed per user.
    # """
    _koopa_print "${XDG_DATA_HOME:?}"
}

_koopa_make_prefix() {  # {{{1
    # """
    # Return the installation prefix to use.
    # @note Updated 2020-02-16.
    # """
    local prefix
    if [ -n "${KOOPA_MAKE_PREFIX:-}" ]
    then
        prefix="$KOOPA_MAKE_PREFIX"
    elif _koopa_is_shared_install
    then
        prefix="/usr/local"
    else
        prefix="$(dirname "${XDG_DATA_HOME:?}")"
    fi
    _koopa_print "$prefix"
}

_koopa_msigdb_prefix() {  # {{{1
    # """
    # MSigDB prefix.
    # @note Updated 2020-05-05.
    # """
    _koopa_print "$(_koopa_refdata_prefix)/msigdb"
}

_koopa_openjdk_prefix() {  # {{{1
    # """
    # OpenJDK prefix.
    # @note Updated 2020-02-27.
    # """
    _koopa_print "$(_koopa_app_prefix)/java/openjdk"
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
    _koopa_print "$prefix"
}

_koopa_prefix() {  # {{{1
    # """
    # Koopa prefix (home).
    # @note Updated 2020-01-12.
    # """
    _koopa_print "${KOOPA_PREFIX:?}"
}

_koopa_pyenv_prefix() {  # {{{1
    # """
    # Python pyenv prefix.
    # @note Updated 2020-05-05.
    #
    # See also approach used for rbenv.
    # """
    _koopa_print "$(_koopa_app_prefix)/python/pyenv"
}

_koopa_python_site_packages_prefix() {
    # """
    # Python 'site-packages' library location.
    # @note Updated 2020-02-10.
    # """
    local python
    python="${1:-"python3"}"
    _koopa_assert_is_installed "$python"
    local x
    x="$("$python" -c "import site; print(site.getsitepackages()[0])")"
    _koopa_print "$x"
}

_koopa_rbenv_prefix() {  # {{{1
    # """
    # Ruby rbenv prefix.
    # @note Updated 2020-05-05.
    #
    # See also:
    # - RBENV_ROOT
    # - https://gist.github.com/saegey/5499096
    # """
    _koopa_print "$(_koopa_app_prefix)/ruby/rbenv"
}

_koopa_refdata_prefix() {  # {{{1
    # """
    # Reference data prefix.
    # @note Updated 2020-05-05.
    # """
    _koopa_print "$(_koopa_data_disk_link_prefix)/refdata"
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
    _koopa_print "$prefix"
}

_koopa_r_prefix() {  # {{{1
    # """
    # R prefix.
    # @note Updated 2020-06-24.
    #
    # We're suppressing errors here that can pop up if 'etc' isn't linked yet
    # after a clean install. Can warn about ldpaths missing.
    # """
    local rscript_exe
    rscript_exe="${1:-Rscript}"
    _koopa_is_installed "$rscript_exe" || return 1
    local prefix
    prefix="$( \
        "$rscript_exe" \
            --vanilla \
            -e 'cat(Sys.getenv("R_HOME"))' \
        2>/dev/null \
    )"
    [ -d "$prefix" ] || return 1
    _koopa_print "$prefix"
    return 0
}

_koopa_r_library_prefix() {  # {{{1
    # """
    # R default library prefix.
    # @note Updated 2020-04-25.
    # """
    local rscript_exe
    rscript_exe="${1:-Rscript}"
    _koopa_is_installed "$rscript_exe" || return 1
    local prefix
    prefix="$("$rscript_exe" -e 'cat(.libPaths()[[1L]])')"
    [ -d "$prefix" ] || return 1
    _koopa_print "$prefix"
    return 0
}

_koopa_r_system_library_prefix() {  # {{{1
    # """
    # R system library prefix.
    # @note Updated 2020-04-25.
    # """
    local rscript_exe
    rscript_exe="${1:-Rscript}"
    _koopa_is_installed "$rscript_exe" || return 1
    local prefix
    prefix="$("$rscript_exe" --vanilla -e 'cat(tail(.libPaths(), n = 1L))')"
    [ -d "$prefix" ] || return 1
    _koopa_print "$prefix"
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
    _koopa_print "$prefix"
}

_koopa_scripts_private_prefix() {  # {{{1
    # """
    # Private scripts prefix.
    # @note Updated 2020-02-15.
    # """
    _koopa_print "$(_koopa_config_prefix)/scripts-private"
}

_koopa_tests_prefix() { # {{{1
    # """
    # Unit tests prefix.
    # @note Updated 2020-06-24.
    # """
    _koopa_print "$(_koopa_prefix)/tests"
}

_koopa_venv_prefix() {  # {{{1
    # """
    # Python venv prefix.
    # @note Updated 2020-05-05.
    # """
    _koopa_print "$(_koopa_app_prefix)/python/virtualenvs"
}
