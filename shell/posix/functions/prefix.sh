#!/bin/sh

koopa::app_prefix() { # {{{1
    # """
    # Custom application install prefix.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_no_args "$#"
    local prefix
    if [ -n "${KOOPA_APP_PREFIX:-}" ]
    then
        prefix="$KOOPA_APP_PREFIX"
    elif koopa::is_shared_install && koopa::is_installed brew
    then
        prefix="$(koopa::prefix)/opt"
    elif koopa::is_shared_install
    then
        prefix="$(koopa::make_prefix)/opt"
    else
        prefix="$(koopa::local_app_prefix)"
    fi
    koopa::print "$prefix"
    return 0
}

koopa::aspera_prefix() { # {{{1
    # """
    # Aspera Connect prefix.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_no_args "$#"
    local prefix
    if koopa::is_shared_install
    then
        prefix="$(koopa::app_prefix)/aspera-connect"
    else
        prefix="${HOME:?}/.aspera/connect"
    fi
    koopa::print "$prefix"
    return 0
}

koopa::autojump_prefix() { # {{{1
    # """
    # autojump prefix.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_no_args "$#"
    local make_prefix prefix
    make_prefix="$(koopa::make_prefix)"
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
    koopa::print "$prefix"
    return 0
}

koopa::bcbio_prefix() { # {{{1
    # """
    # bcbio-nextgen prefix.
    # @note Updated 2020-07-03.
    koopa::assert_has_no_args "$#"
    koopa::assert_is_linux
    local host_id prefix
    host_id="$(koopa::host_id)"
    if [ "$host_id" = "harvard-o2" ]
    then
        prefix="/n/app/bcbio/tools"
    elif [ "$host_id" = "harvard-odyssey" ]
    then
        prefix="/n/regal/hsph_bioinfo/bcbio_nextgen"
    else
        prefix="$(koopa::app_prefix)/bcbio/stable/tools"
    fi
    koopa::print "$prefix"
    return 0
}

koopa::cellar_prefix() { # {{{1
    # """
    # Cellar prefix.
    # @note Updated 2020-07-03.
    #
    # Currently only supported for Linux.
    # Use Homebrew on macOS instead.
    #
    # Ensure this points to a local mount (e.g. '/usr/local').
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_linux
    local prefix
    if [ -n "${KOOPA_CELLAR_PREFIX:-}" ]
    then
        prefix="$KOOPA_CELLAR_PREFIX"
    elif koopa::is_shared_install && koopa::is_installed brew
    then
        prefix="$(koopa::prefix)/cellar"
    else
        prefix="$(koopa::make_prefix)/cellar"
    fi
    koopa::print "$prefix"
    return 0
}

koopa::conda_prefix() { # {{{1
    # """
    # Conda prefix.
    # @note Updated 2020-07-01.
    # @seealso conda info --base
    # """
    koopa::assert_has_no_args "$#"
    local prefix
    if [ -n "${CONDA_EXE:-}" ]
    then
        prefix="$(cd "$(dirname "$CONDA_EXE")/.." &>/dev/null && pwd -P)"
    else
        prefix="$(koopa::app_prefix)/conda"
    fi
    koopa::print "$prefix"
    return 0
}

koopa::config_prefix() { # {{{1
    # """
    # Local koopa config directory.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "${XDG_CONFIG_HOME:-"${HOME:?}/.config"}/koopa"
    return 0
}

koopa::data_disk_link_prefix() { # {{{1
    # """
    # Data disk symlink prefix.
    # @note Updated 2020-07-03.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_linux
    koopa::print "/n"
    return 0
}

koopa::docker_prefix() { # {{{1
    # """
    # Docker prefix.
    # @note Updated 2020-02-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "$(koopa::config_prefix)/docker"
    return 0
}

koopa::docker_private_prefix() { # {{{1
    # """
    # Private Docker prefix.
    # @note Updated 2020-03-05.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "$(koopa::config_prefix)/docker-private"
    return 0
}

koopa::dotfiles_prefix() { # {{{1
    # """
    # Koopa system dotfiles prefix.
    # @note Updated 2020-05-05.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "$(koopa::prefix)/dotfiles"
    return 0
}

koopa::dotfiles_private_prefix() { # {{{1
    # """
    # Private user dotfiles prefix.
    # @note Updated 2020-02-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "$(koopa::config_prefix)/dotfiles-private"
    return 0
}

koopa::emacs_prefix() { # {{{1
    # """
    # Default Emacs prefix.
    # @note Updated 2020-06-29.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "${HOME}/.emacs.d"
    return 0
}

koopa::ensembl_perl_api_prefix() { # {{{1
    # """
    # Ensembl Perl API prefix.
    # @note Updated 2019-11-15.
    koopa::assert_has_no_args "$#"
    koopa::print "$(koopa::app_prefix)/ensembl"
    return 0
}

koopa::fzf_prefix() { # {{{1
    # """
    # fzf prefix.
    # @note Updated 2020-03-16.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "$(koopa::app_prefix)/fzf"
    return 0
}

koopa::go_gopath() { # {{{1
    # """
    # Go GOPATH, for building from source.
    # @note Updated 2020-07-01.
    #
    # This must be different from go root.
    #
    # @seealso
    # - go help gopath
    # - go env GOPATH
    # - go env GOROOT
    # - https://golang.org/wiki/SettingGOPATH to set a custom GOPATH
    # """
    koopa::assert_has_no_args "$#"
    local prefix
    if [ -n "${GOPATH:-}" ]
    then
        prefix="$GOPATH"
    else
        prefix="$(koopa::app_prefix)/go/gopath"
    fi
    koopa::print "$prefix"
    return 0
}

koopa::homebrew_cellar_prefix() { # {{{1
    # """
    # Homebrew cellar prefix.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "$(koopa::homebrew_prefix)/Cellar"
    return 0
}

koopa::homebrew_prefix() { # {{{1
    # """
    # Homebrew prefix.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_no_args "$#"
    local prefix
    prefix="${HOMEBREW_PREFIX:-/usr/local}"
    koopa::print "$prefix"
    return 0
}

koopa::homebrew_ruby_gems_prefix() { # {{{1
    # """
    # Homebrew Ruby gems prefix.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_installed ruby || return 0
    local homebrew_prefix
    homebrew_prefix="$(koopa::homebrew_prefix)"
    local api_version
    api_version="$(koopa::ruby_api_version)"
    local prefix
    prefix="${homebrew_prefix}/lib/ruby/gems/${api_version}/bin"
    koopa::print "$prefix"
    return 0
}

koopa::include_prefix() { # {{{1
    # """
    # Koopa system includes prefix.
    # @note Updated 2020-07-02.
    # """
    koopa::assert_has_no_args "$#"
    local prefix
    prefix="$(koopa::prefix)/include"
    [ -d "$prefix" ] || return 1
    koopa::print "$prefix"
    return 0
}

koopa::java_prefix() { # {{{1
    # """
    # Java prefix.
    # @note Updated 2020-07-01.
    #
    # See also:
    # - https://www.mkyong.com/java/
    #       how-to-set-java_home-environment-variable-on-mac-os-x/
    # - https://stackoverflow.com/questions/22290554
    # """
    koopa::assert_has_no_args "$#"
    local prefix
    if [ -n "${JAVA_HOME:-}" ]
    then
        # Allow user to override default.
        prefix="$JAVA_HOME"
    elif [ -x "/usr/libexec/java_home" ]
    then
        # Handle macOS config.
        prefix="$(/usr/libexec/java_home)"
    else
        # Otherwise assume latest OpenJDK.
        # This works on Linux installs, including Docker images.
        prefix="$(koopa::openjdk_prefix)/latest"
    fi
    koopa::print "$prefix"
    return 0
}

koopa::local_app_prefix() { # {{{1
    # """
    # Local user application install prefix.
    # @note Updated 2020-07-01.
    #
    # This is the default app path when koopa is installed per user.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "${XDG_DATA_HOME:?}"
    return 0
}

koopa::make_prefix() { # {{{1
    # """
    # Return the installation prefix to use.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_no_args "$#"
    local prefix
    if [ -n "${KOOPA_MAKE_PREFIX:-}" ]
    then
        prefix="$KOOPA_MAKE_PREFIX"
    elif koopa::is_shared_install
    then
        prefix="/usr/local"
    else
        prefix="$(dirname "${XDG_DATA_HOME:?}")"
    fi
    koopa::print "$prefix"
    return 0
}

koopa::msigdb_prefix() { # {{{1
    # """
    # MSigDB prefix.
    # @note Updated 2020-05-05.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "$(koopa::refdata_prefix)/msigdb"
    return 0
}

koopa::monorepo_prefix() { # {{{1
    # """
    # Git monorepo prefix.
    # @note Updated 2020-07-03.
    # """
    koopa::print "${HOME:?}/monorepo"
    return 0
}

koopa::openjdk_prefix() { # {{{1
    # """
    # OpenJDK prefix.
    # @note Updated 2020-02-27.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "$(koopa::app_prefix)/java/openjdk"
    return 0
}

koopa::perlbrew_prefix() { # {{{1
    # """
    # Perlbrew prefix.
    # @note Updated 2020-01-12.
    # """
    koopa::assert_has_no_args "$#"
    local prefix
    if [ -n "${PERLBREW_ROOT:-}" ]
    then
        prefix="$PERLBREW_ROOT"
    else
        prefix="$(koopa::app_prefix)/perl/perlbrew"
    fi
    koopa::print "$prefix"
    return 0
}

koopa::prefix() { # {{{1
    # """
    # Koopa prefix (home).
    # @note Updated 2020-01-12.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "${KOOPA_PREFIX:?}"
    return 0
}

koopa::pyenv_prefix() { # {{{1
    # """
    # Python pyenv prefix.
    # @note Updated 2020-05-05.
    #
    # See also approach used for rbenv.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "$(koopa::app_prefix)/python/pyenv"
    return 0
}

koopa::python_site_packages_prefix() {
    # """
    # Python site packages library location.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_args_le "$#" 1
    local python
    python="${1:-"python3"}"
    koopa::assert_is_installed "$python"
    local x
    x="$("$python" -c "import site; print(site.getsitepackages()[0])")"
    koopa::print "$x"
    return 0
}

koopa::rbenv_prefix() { # {{{1
    # """
    # Ruby rbenv prefix.
    # @note Updated 2020-05-05.
    #
    # See also:
    # - RBENV_ROOT
    # - https://gist.github.com/saegey/5499096
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "$(koopa::app_prefix)/ruby/rbenv"
    return 0
}

koopa::refdata_prefix() { # {{{1
    # """
    # Reference data prefix.
    # @note Updated 2020-05-05.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "$(koopa::data_disk_link_prefix)/refdata"
    return 0
}

koopa::rust_cargo_prefix() { # {{{1
    # """
    # Rust cargo install prefix.
    # @note Updated 2020-01-12.
    #
    # See also:
    # - https://github.com/rust-lang/rustup#environment-variables
    # - CARGO_HOME
    # - RUSTUP_HOME
    # """
    koopa::assert_has_no_args "$#"
    local prefix
    if koopa::is_shared_install
    then
        prefix="$(koopa::app_prefix)/rust/cargo"
    else
        prefix="${HOME:?}/.cargo"
    fi
    koopa::print "$prefix"
    return 0
}

koopa::rust_rustup_prefix() { # {{{1
    # """
    # Rust rustup install prefix.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_no_args "$#"
    local prefix
    if koopa::is_shared_install
    then
        prefix="$(koopa::app_prefix)/rust/rustup"
    else
        prefix="${HOME:?}/.rustup"
    fi
    koopa::print "$prefix"
    return 0
}

koopa::scripts_private_prefix() { # {{{1
    # """
    # Private scripts prefix.
    # @note Updated 2020-02-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "$(koopa::config_prefix)/scripts-private"
    return 0
}

koopa::tests_prefix() { # {{{1
    # """
    # Unit tests prefix.
    # @note Updated 2020-06-24.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "$(koopa::prefix)/tests"
    return 0
}

koopa::venv_prefix() { # {{{1
    # """
    # Python venv prefix.
    # @note Updated 2020-05-05.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "$(koopa::app_prefix)/python/virtualenvs"
    return 0
}
