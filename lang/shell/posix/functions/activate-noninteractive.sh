#!/bin/sh

_koopa_activate_anaconda() { # {{{1
    # """
    # Activate Anaconda.
    # @note Updated 2021-10-26.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_activate_conda "$(_koopa_anaconda_prefix)"
    return 0
}

_koopa_activate_aspera() { # {{{1
    # """
    # Include Aspera Connect binaries in PATH, if defined.
    # @note Updated 2021-09-15.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_activate_prefix "$(_koopa_aspera_prefix)"
    return 0
}

_koopa_activate_bcbio_nextgen() { # {{{1
    # """
    # Activate bcbio-nextgen tool binaries.
    # @note Updated 2021-06-11.
    #
    # Attempt to locate bcbio installation automatically on supported platforms.
    #
    # Exporting at the end of PATH so we don't mask gcc or R.
    # This is particularly important to avoid unexpected compilation issues
    # due to compilers in conda masking the system versions.
    # """
    local prefix
    [ "$#" -eq 0 ] || return 1
    prefix="$(_koopa_bcbio_nextgen_tools_prefix)"
    [ -d "$prefix" ] || return 0
    _koopa_add_to_path_end "${prefix}/bin"
    unset -v PYTHONHOME PYTHONPATH
    return 0
}

_koopa_activate_conda() { # {{{1
    # """
    # Activate conda using 'activate' script.
    # @note Updated 2021-11-01.
    #
    # Prefer Miniconda over Anaconda by default, if both are installed.
    # """
    local anaconda_prefix conda_prefix name nounset prefix
    [ "$#" -le 1 ] || return 1
    prefix="${1:-}"
    if [ -z "$prefix" ]
    then
        conda_prefix="$(_koopa_conda_prefix)"
        anaconda_prefix="$(_koopa_anaconda_prefix)"
        if [ -d "$conda_prefix" ]
        then
            prefix="$conda_prefix"
        elif [ -d "$anaconda_prefix" ]
        then
            prefix="$anaconda_prefix"
        fi
    fi
    [ -d "$prefix" ] || return 0
    script="${prefix}/bin/activate"
    [ -r "$script" ] || return 0
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    # shellcheck source=/dev/null
    . "$script"
    # Ensure the base environment is deactivated by default.
    conda deactivate
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_emacs() { # {{{1
    # """
    # Activate Emacs.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_activate_prefix "${HOME}/.emacs.d"
    return 0
}

_koopa_activate_go() { # {{{1
    # """
    # Activate Go.
    # @note Updated 2021-05-26.
    # """
    local prefix
    [ "$#" -eq 0 ] || return 1
    prefix="$(_koopa_go_prefix)"
    [ -d "$prefix" ] && _koopa_activate_prefix "$prefix"
    _koopa_is_installed go || return 0
    GOPATH="$(_koopa_go_packages_prefix)"
    export GOPATH
    return 0
}

_koopa_activate_homebrew() { # {{{1
    # """
    # Activate Homebrew.
    # @note Updated 2021-12-01.
    #
    # Don't activate 'binutils' here. Can mess up R package compilation.
    # """
    local prefix
    [ "$#" -eq 0 ] || return 1
    prefix="$(_koopa_homebrew_prefix)"
    _koopa_activate_prefix "$prefix"
    _koopa_is_installed 'brew' || return 0
    export HOMEBREW_INSTALL_CLEANUP=1
    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_AUTO_UPDATE=1
    export HOMEBREW_NO_ENV_HINTS=1
    export HOMEBREW_PREFIX="$prefix"
    _koopa_is_macos || return 0
    _koopa_activate_homebrew_opt_prefix \
        'bc' \
        'curl' \
        'gnu-getopt' \
        'ncurses' \
        'openssl' \
        'ruby' \
        'texinfo'
    _koopa_activate_homebrew_opt_libexec_prefix \
        'man-db'
    _koopa_activate_homebrew_opt_gnu_prefix \
        'coreutils' \
        'findutils' \
        'gnu-sed' \
        'gnu-tar' \
        'gnu-which' \
        'grep' \
        'make'
    # Casks are macOS-specific.
    _koopa_activate_homebrew_cask_google_cloud_sdk
    export HOMEBREW_CASK_OPTS='--no-binaries --no-quarantine'
    return 0
}

_koopa_activate_homebrew_cask_google_cloud_sdk() { # {{{1
    # """
    # Activate Homebrew Google Cloud SDK.
    # @note Updated 2021-11-04.
    #
    # The SDK doesn't currently support Python 3.10, so pinning to 3.9.
    # """
    local brew_prefix prefix python
    [ "$#" -eq 0 ] || return 1
    brew_prefix="$(_koopa_homebrew_prefix)"
    prefix="${brew_prefix}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
    _koopa_activate_prefix "$prefix"
    # Need to pin to Python 3.9, since 3.10 isn't currently supported.
    python="${brew_prefix}/opt/python@3.9/bin/python3.9"
    export CLOUDSDK_PYTHON="$python"
    # Alternate (slower) approach that enables autocompletion.
    # > local shell
    # > [ -d "$prefix" ] || return 0
    # > shell="$(_koopa_shell_name)"
    # > # shellcheck source=/dev/null
    # > [ -f "${prefix}/path.${shell}.inc" ] && \
    # >     . "${prefix}/path.${shell}.inc"
    # > # shellcheck source=/dev/null
    # > [ -f "${prefix}/completion.${shell}.inc" ] && \
    # >     . "${prefix}/completion.${shell}.inc"
    return 0
}

# FIXME Need corresponding deactivate function, which is useful for scripting.
_koopa_activate_homebrew_opt_gnu_prefix() { # {{{1
    # """
    # Activate Homebrew opt prefix for a GNU program.
    # @note Updated 2021-09-14.
    #
    # Linked using 'g' prefix by default.
    #
    # Note that libtool is always prefixed with 'g', even in 'opt/'.
    #
    # @examples
    # _koopa_activate_homebrew_opt_gnu_prefix 'binutils' 'coreutils'
    # """
    local homebrew_prefix name prefix
    [ "$#" -gt 0 ] || return 1
    homebrew_prefix="$(_koopa_homebrew_prefix)"
    for name in "$@"
    do
        prefix="${homebrew_prefix}/opt/${name}/libexec"
        if [ ! -d "$prefix" ]
        then
            _koopa_warn "Not installed: '${prefix}'."
            return 1
        fi
        _koopa_add_to_path_start \
            "${prefix}/gnubin"
        _koopa_add_to_manpath_start \
            "${prefix}/gnuman"
        _koopa_add_to_pkg_config_path_start \
            "${prefix}/lib/pkgconfig" \
            "${prefix}/share/pkgconfig"
    done
    return 0
}

# FIXME Need corresponding deactivate function, which is useful for scripting.
_koopa_activate_homebrew_opt_libexec_prefix() { # {{{1
    # """
    # Activate Homebrew opt libexec prefix.
    # @note Updated 2021-09-20.
    # """
    local homebrew_prefix name prefix
    [ "$#" -gt 0 ] || return 1
    homebrew_prefix="$(_koopa_homebrew_prefix)"
    for name in "$@"
    do
        prefix="${homebrew_prefix}/opt/${name}/libexec"
        if [ ! -d "$prefix" ]
        then
            _koopa_warn "Not installed: '${prefix}'."
            return 1
        fi
        _koopa_activate_prefix "$prefix"
    done
    return 0
}

# FIXME Need corresponding deactivate function, which is useful for scripting.
_koopa_activate_homebrew_opt_prefix() { # {{{1
    # """
    # Activate Homebrew opt prefix.
    # @note Updated 2021-09-15.
    # """
    local homebrew_prefix name prefix
    [ "$#" -gt 0 ] || return 1
    homebrew_prefix="$(_koopa_homebrew_prefix)"
    for name in "$@"
    do
        prefix="${homebrew_prefix}/opt/${name}"
        if [ ! -d "$prefix" ]
        then
            _koopa_warn "Not installed: '${prefix}'."
            return 1
        fi
        _koopa_activate_prefix "$prefix"
    done
    return 0
}

_koopa_activate_julia() { # {{{1
    # """
    # Activate Julia.
    # @note Updated 2021-06-14.
    # """
    local prefix
    if _koopa_is_macos
    then
        prefix="$(_koopa_macos_julia_prefix)"
        _koopa_activate_prefix "$prefix"
    fi
    prefix="$(_koopa_julia_packages_prefix)"
    if [ -d "$prefix" ]
    then
        export JULIA_DEPOT_PATH="$prefix"
    fi
    return 0
}

_koopa_activate_koopa_paths() { # {{{1
    # """
    # Automatically configure koopa PATH and MANPATH.
    # @note Updated 2021-01-19.
    # """
    local config_prefix distro_prefix koopa_prefix linux_prefix shell
    [ "$#" -eq 0 ] || return 1
    koopa_prefix="$(_koopa_koopa_prefix)"
    config_prefix="$(_koopa_config_prefix)"
    shell="$(_koopa_shell_name)"
    _koopa_activate_prefix "$koopa_prefix"
    _koopa_activate_prefix "${koopa_prefix}/lang/shell/${shell}"
    if _koopa_is_linux
    then
        linux_prefix="${koopa_prefix}/os/linux"
        distro_prefix="${linux_prefix}/distro"
        _koopa_activate_prefix "${linux_prefix}/common"
        if _koopa_is_debian_like
        then
            _koopa_activate_prefix "${distro_prefix}/debian"
            _koopa_is_ubuntu_like && \
                _koopa_activate_prefix "${distro_prefix}/ubuntu"
        elif _koopa_is_fedora_like
        then
            _koopa_activate_prefix "${distro_prefix}/fedora"
            _koopa_is_rhel_like && \
                _koopa_activate_prefix "${distro_prefix}/rhel"
        fi
    fi
    _koopa_activate_prefix "$(_koopa_distro_prefix)"
    _koopa_activate_prefix "${config_prefix}/scripts-private"
    return 0
}

_koopa_activate_local_etc_profile() { # {{{1
    # """
    # Source 'profile.d' scripts in '/usr/local/etc'.
    # @note Updated 2020-08-05.
    #
    # Currently only supported for Bash.
    # """
    local make_prefix prefix shell
    [ "$#" -eq 0 ] || return 1
    shell="$(_koopa_shell_name)"
    case "$shell" in
        'bash')
            ;;
        *)
            return 0
            ;;
    esac
    make_prefix="$(_koopa_make_prefix)"
    prefix="${make_prefix}/etc/profile.d"
    [ -d "$prefix" ] || return 0
    for script in "${prefix}/"*'.sh'
    do
        if [ -r "$script" ]
        then
            # shellcheck source=/dev/null
            . "$script"
        fi
    done
    return 0
}

_koopa_activate_local_paths() { # {{{1
    # """
    # Activate local user paths.
    # @note Updated 2021-05-20.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_activate_prefix "$(_koopa_xdg_local_home)"
    _koopa_add_to_path_start "${HOME:?}/bin"
    return 0
}

_koopa_activate_make_paths() { # {{{1
    # """
    # Activate standard Makefile paths.
    # @note Updated 2021-09-14.
    #
    # Note that here we're making sure local binaries are included.
    # Inspect '/etc/profile' if system PATH appears misconfigured.
    #
    # Note that macOS Big Sur includes '/usr/local/bin' automatically now,
    # resulting in a duplication. This is OK.
    # Refer to '/etc/paths.d' for other system paths.
    #
    # @seealso
    # - https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard
    # """
    local make_prefix
    [ "$#" -eq 0 ] || return 1
    make_prefix="$(_koopa_make_prefix)"
    _koopa_add_to_path_start \
        "${make_prefix}/bin" \
        "${make_prefix}/sbin"
    _koopa_add_to_manpath_start \
        "${make_prefix}/man" \
        "${make_prefix}/share/man"
    return 0
}

_koopa_activate_nextflow() { # {{{1
    # """
    # Activate Nextflow configuration.
    # @note Updated 2020-07-21.
    # @seealso
    # - https://github.com/nf-core/smrnaseq/blob/master/docs/usage.md
    # """
    [ "$#" -eq 0 ] || return 1
    [ -z "${NXF_OPTS:-}" ] || return 0
    export NXF_OPTS='-Xms1g -Xmx4g'
    return 0
}

_koopa_activate_nim() { # {{{1
    # """
    # Activate Nim.
    # @note Updated 2021-09-29.
    # """
    local prefix
    [ "$#" -eq 0 ] || return 1
    prefix="$(_koopa_nim_packages_prefix)"
    [ -d "$prefix" ] || return 0
    _koopa_activate_prefix "$prefix"
    export NIMBLE_DIR="$prefix"
    return 0
}

_koopa_activate_node() { # {{{1
    # """
    # Activate Node.js (and NPM).
    # @note Updated 2021-05-25.
    # """
    local prefix
    [ "$#" -eq 0 ] || return 1
    prefix="$(_koopa_node_packages_prefix)"
    [ -d "$prefix" ] || return 0
    _koopa_activate_prefix "$prefix"
    export NPM_CONFIG_PREFIX="$prefix"
    return 0
}

_koopa_activate_openjdk() { # {{{1
    # """
    # Activate OpenJDK.
    # @note Updated 2021-09-14.
    #
    # Use Homebrew instead to manage on macOS.
    #
    # We're using a symlink approach here to manage versions.
    # """
    local prefix
    [ "$#" -eq 0 ] || return 1
    prefix="$(_koopa_java_prefix || true)"
    [ -d "$prefix" ] && _koopa_activate_prefix "$prefix"
    return 0
}

# FIXME Need corresponding deactivate function, which is useful for scripting.
_koopa_activate_opt_prefix() { # {{{1
    # """
    # Activate koopa opt prefix.
    # @note Updated 2021-05-26.
    #
    # @examples
    # _koopa_activate_opt_prefix 'geos' 'proj' 'gdal'
    # """
    local name opt_prefix prefix
    [ "$#" -gt 0 ] || return 1
    opt_prefix="$(_koopa_opt_prefix)"
    for name in "$@"
    do
        prefix="${opt_prefix}/${name}"
        if [ ! -d "$prefix" ]
        then
            _koopa_warn "Not installed: '${prefix}'."
            return 1
        fi
        _koopa_activate_prefix "$prefix"
    done
    return 0
}

_koopa_activate_perl() { # {{{1
    # """
    # Activate Perl, adding local library to 'PATH'.
    # @note Updated 2021-09-17.
    #
    # No longer querying Perl directly here, to speed up shell activation
    # (see commented legacy approach below).
    #
    # The legacy Perl eval approach may error/warn if new shell is activated
    # while Perl packages are installing.
    #
    # @seealso
    # - brew info perl
    # """
    local prefix
    [ "$#" -eq 0 ] || return 1
    prefix="$(_koopa_perl_packages_prefix)"
    [ -d "$prefix" ] || return 0
    # Legacy approach that doesn't propagate in subshells correctly:
    # > _koopa_is_installed perl || return 0
    # > eval "$( \
    # >     perl \
    # >         "-I${prefix}/lib/perl5" \
    # >         "-Mlocal::lib=${prefix}" \
    # > )"
    _koopa_activate_prefix "$prefix"
    export PERL5LIB="${prefix}/lib/perl5"
    export PERL_LOCAL_LIB_ROOT="$prefix"
    export PERL_MB_OPT="--install_base '${prefix}'"
    export PERL_MM_OPT="INSTALL_BASE=${prefix}"
    export PERL_MM_USE_DEFAULT=1
    return 0
}

_koopa_activate_perlbrew() { # {{{1
    # """
    # Activate Perlbrew.
    # @note Updated 2020-06-30.
    #
    # Only attempt to autoload for bash or zsh.
    # Delete '~/.perlbrew' directory if you see errors at login.
    #
    # See also:
    # - https://perlbrew.pl
    # """
    local nounset prefix script shell
    [ "$#" -eq 0 ] || return 1
    [ -n "${PERLBREW_ROOT:-}" ] && return 0
    ! _koopa_is_installed perlbrew || return 0
    shell="$(_koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    prefix="$(_koopa_perlbrew_prefix)"
    [ -d "$prefix" ] || return 0
    script="${prefix}/etc/bashrc"
    [ -r "$script" ] || return 0
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    # Note that this is also compatible with zsh.
    # shellcheck source=/dev/null
    . "$script"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_pipx() { # {{{1
    # """
    # Activate pipx for Python.
    # @note Updated 2021-04-23.
    #
    # Customize pipx location with environment variables.
    # https://pipxproject.github.io/pipx/installation/
    # """
    local prefix
    [ "$#" -eq 0 ] || return 1
    _koopa_is_installed pipx || return 0
    prefix="$(_koopa_pipx_prefix)"
    PIPX_HOME="$prefix"
    PIPX_BIN_DIR="${prefix}/bin"
    _koopa_add_to_path_start "$PIPX_BIN_DIR"
    export PIPX_HOME PIPX_BIN_DIR
    return 0
}

_koopa_activate_pkg_config() { # {{{1
    # """
    # Configure PKG_CONFIG_PATH.
    # @note Updated 2021-09-14.
    #
    # Typical priorities (e.g. on Debian):
    # - /usr/local/lib/x86_64-linux-gnu/pkgconfig
    # - /usr/local/lib/pkgconfig
    # - /usr/local/share/pkgconfig
    # - /usr/lib/x86_64-linux-gnu/pkgconfig
    # - /usr/lib/pkgconfig
    # - /usr/share/pkgconfig
    #
    # These are defined primarily for R environment. In particular these make
    # building tricky pages from source, such as rgdal, sf and others  easier.
    #
    # This is necessary for rgdal, sf packages to install clean.
    #
    # @seealso
    # - https://askubuntu.com/questions/210210/
    # """
    local homebrew_prefix make_prefix
    [ "$#" -eq 0 ] || return 1
    homebrew_prefix="$(_koopa_homebrew_prefix)"
    make_prefix="$(_koopa_make_prefix)"
    _koopa_add_to_pkg_config_path_start_2 \
        '/usr/bin/pkg-config'
    if [ "$homebrew_prefix" != "$make_prefix" ]
    then
        _koopa_add_to_pkg_config_path_start_2 \
            "${homebrew_prefix}/bin/pkg-config"
    fi
    _koopa_add_to_pkg_config_path_start_2 \
        "${make_prefix}/bin/pkg-config"
    return 0
}

# FIXME Need corresponding deactivate function, which is useful for scripting.
_koopa_activate_prefix() { # {{{1
    # """
    # Automatically configure 'PATH', 'PKG_CONFIG_PATH' and 'MANPATH' for a
    # specified prefix.
    # @note Updated 2021-09-14.
    # """
    local prefix
    [ "$#" -gt 0 ] || return 1
    for prefix in "$@"
    do
        [ -d "$prefix" ] || continue
        _koopa_add_to_path_start \
            "${prefix}/bin" \
            "${prefix}/sbin"
        _koopa_add_to_manpath_start \
            "${prefix}/man" \
            "${prefix}/share/man"
        _koopa_add_to_pkg_config_path_start \
            "${prefix}/lib/pkgconfig" \
            "${prefix}/share/pkgconfig"
    done
    return 0
}

_koopa_activate_pyenv() { # {{{1
    # """
    # Activate Python version manager (pyenv).
    # @note Updated 2020-06-30.
    #
    # Note that pyenv forks rbenv, so activation is very similar.
    # """
    local nounset prefix script
    [ "$#" -eq 0 ] || return 1
    _koopa_is_installed pyenv && return 0
    [ -n "${PYENV_ROOT:-}" ] && return 0
    prefix="$(_koopa_pyenv_prefix)"
    [ -d "$prefix" ] || return 0
    script="${prefix}/bin/pyenv"
    [ -r "$script" ] || return 0
    export PYENV_ROOT="$prefix"
    _koopa_activate_prefix "$prefix"
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    eval "$("$script" init -)"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_python() { # {{{1
    # """
    # Activate Python.
    # @note Updated 2021-10-27.
    #
    # Configures:
    # - Site packages library.
    # - Custom startup file, defined in our 'dotfiles' repo.
    #
    # This ensures that 'bin' will be added to PATH, which is useful when
    # installing via pip with '--target' flag.
    #
    # @seealso
    # - https://stackoverflow.com/questions/33683744/
    # - https://twitter.com/sadhlife/status/1450459992419622920
    # - https://docs.python-guide.org/dev/pip-virtualenv/
    # """
    local prefix startup_file
    [ "$#" -eq 0 ] || return 1
    if _koopa_is_macos
    then
        prefix="$(_koopa_macos_python_prefix)"
        _koopa_activate_prefix "$prefix"
    fi
    prefix="$(_koopa_python_packages_prefix)"
    _koopa_activate_prefix "$prefix"
    if [ -z "${PIP_REQUIRE_VIRTUALENV:-}" ]
    then
        export PIP_REQUIRE_VIRTUALENV='true'
    fi
    if [ -z "${VIRTUAL_ENV_DISABLE_PROMPT:-}" ]
    then
        export VIRTUAL_ENV_DISABLE_PROMPT=1
    fi
    startup_file="${HOME:?}/.pyrc"
    if [ -z "${PYTHONSTARTUP:-}" ] && [ -f "$startup_file" ]
    then
        export PYTHONSTARTUP="$startup_file"
    fi
    return 0
}

_koopa_activate_python_venv() { # {{{1
    # """
    # Activate Python virtual environment.
    # @note Updated 2020-06-30.
    #
    # Note that we're using this instead of conda as our default interactive
    # Python environment, so we can easily use pip.
    #
    # Here's how to write a function to detect virtual environment name:
    # https://stackoverflow.com/questions/10406926
    #
    # Only attempt to autoload for bash or zsh.
    #
    # This needs to be run last, otherwise PATH can get messed upon
    # deactivation, due to venv's current poor approach via '_OLD_VIRTUAL_PATH'.
    #
    # Refer to 'declare -f deactivate' for function source code.
    # """
    local name nounset prefix script shell
    [ "$#" -le 1 ] || return 1
    [ -n "${VIRTUAL_ENV:-}" ] && return 0
    shell="$(_koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    name="${1:-base}"
    prefix="$(_koopa_python_venv_prefix)"
    script="${prefix}/${name}/bin/activate"
    [ -r "$script" ] || return 0
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    # shellcheck source=/dev/null
    . "$script"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_rbenv() { # {{{1
    # """
    # Activate Ruby version manager (rbenv).
    # @note Updated 2020-06-30.
    #
    # See also:
    # - https://github.com/rbenv/rbenv
    # """
    local nounset prefix script
    [ "$#" -eq 0 ] || return 1
    if _koopa_is_installed 'rbenv'
    then
        eval "$(rbenv init -)"
        return 0
    fi
    [ -n "${RBENV_ROOT:-}" ] && return 0
    prefix="$(_koopa_rbenv_prefix)"
    [ -d "$prefix" ] || return 0
    script="${prefix}/bin/rbenv"
    [ -r "$script" ] || return 0
    export RBENV_ROOT="$prefix"
    _koopa_activate_prefix "$prefix"
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    eval "$("$script" init -)"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_ruby() { # {{{1
    # """
    # Activate Ruby gems.
    # @note Updated 2021-05-04.
    # """
    local prefix
    [ "$#" -eq 0 ] || return 1
    prefix="$(_koopa_ruby_packages_prefix)"
    _koopa_activate_prefix "$prefix"
    export GEM_HOME="$prefix"
    return 0
}

_koopa_activate_rust() { # {{{1
    # """
    # Activate Rust programming language.
    # @note Updated 2021-09-20.
    #
    # Attempt to locate cargo home and source the 'env' script.
    # This will put the rust cargo programs defined in 'bin/' in the PATH.
    #
    # Alternatively, can just add '${cargo_home}/bin' to PATH.
    # """
    local cargo_prefix rustup_prefix
    [ "$#" -eq 0 ] || return 1
    cargo_prefix="$(_koopa_rust_packages_prefix)"
    rustup_prefix="$(_koopa_rust_prefix)"
    if [ -d "$cargo_prefix" ]
    then
        _koopa_add_to_path_start "${cargo_prefix}/bin"
        export CARGO_HOME="$cargo_prefix"
    fi
    if [ -d "$rustup_prefix" ]
    then
        export RUSTUP_HOME="$rustup_prefix"
    fi
    return 0
}

_koopa_activate_secrets() { # {{{1
    # """
    # Source secrets file.
    # @note Updated 2020-07-07.
    # """
    local file
    [ "$#" -le 1 ] || return 1
    file="${1:-}"
    [ -z "$file" ] && file="${HOME}/.secrets"
    [ -r "$file" ] || return 0
    # shellcheck source=/dev/null
    . "$file"
    return 0
}

_koopa_activate_ssh_key() { # {{{1
    # """
    # Import an SSH key automatically.
    # @note Updated 2021-05-26.
    #
    # NOTE: SCP will fail unless this is interactive only.
    # ssh-agent will prompt for password if there's one set.
    #
    # To change SSH key passphrase:
    # > ssh-keygen -p
    #
    # List currently loaded keys:
    # > ssh-add -L
    # """
    local key
    [ "$#" -le 1 ] || return 1
    _koopa_is_linux || return 0
    key="${1:-}"
    if [ -z "$key" ] && [ -n "${SSH_KEY:-}" ]
    then
        key="$SSH_KEY"
    else
        key="${HOME}/.ssh/id_rsa"
    fi
    [ -r "$key" ] || return 0
    eval "$(ssh-agent -s)" >/dev/null 2>&1
    ssh-add "$key" >/dev/null 2>&1
    return 0
}

_koopa_activate_xdg() { # {{{1
    # """
    # Activate XDG base directory specification.
    # @note Updated 2021-06-11.
    # @seealso
    # - https://developer.gnome.org/basedir-spec/
    # - https://specifications.freedesktop.org/basedir-spec/
    #     basedir-spec-latest.html#variables
    # - https://wiki.archlinux.org/index.php/XDG_Base_Directory
    # - https://unix.stackexchange.com/questions/476963/
    # """
    [ "$#" -eq 0 ] || return 1
    # XDG_CACHE_HOME.
    if [ -z "${XDG_CACHE_HOME:-}" ]
    then
        XDG_CACHE_HOME="$(_koopa_xdg_cache_home)"
    fi
    export XDG_CACHE_HOME
    # XDG_CONFIG_DIRS.
    if [ -z "${XDG_CONFIG_DIRS:-}" ]
    then
        XDG_CONFIG_DIRS="$(_koopa_xdg_config_dirs)"
    fi
    export XDG_CONFIG_DIRS
    # XDG_CONFIG_HOME.
    if [ -z "${XDG_CONFIG_HOME:-}" ]
    then
        XDG_CONFIG_HOME="$(_koopa_xdg_config_home)"
    fi
    export XDG_CONFIG_HOME
    # XDG_DATA_DIRS.
    if [ -z "${XDG_DATA_DIRS:-}" ]
    then
        XDG_DATA_DIRS="$(_koopa_xdg_data_dirs)"
    fi
    export XDG_DATA_DIRS
    # XDG_DATA_HOME.
    if [ -z "${XDG_DATA_HOME:-}" ]
    then
        XDG_DATA_HOME="$(_koopa_xdg_data_home)"
    fi
    export XDG_DATA_HOME
    # XDG_RUNTIME_DIR.
    if [ -z "${XDG_RUNTIME_DIR:-}" ]
    then
        XDG_RUNTIME_DIR="$(_koopa_xdg_runtime_dir)"
    fi
    if [ ! -d "$XDG_RUNTIME_DIR" ]
    then
        unset -v XDG_RUNTIME_DIR
    else
        export XDG_RUNTIME_DIR
    fi
    return 0
}

_koopa_macos_activate_gpg_suite() { # {{{1
    # """
    # Activate MacGPG (gpg-suite) on macOS.
    # @note Updated 2021-06-14.
    #
    # This code shouldn't be necessary to run at startup, since MacGPG2
    # should be configured at '/private/etc/paths.d/MacGPG2' automatically.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_activate_prefix '/usr/local/MacGPG2'
    return 0
}

_koopa_macos_activate_r() { # {{{1
    # """
    # Activate R on macOS.
    # @note Updated 2021-06-14.
    # """
    local prefix
    [ "$#" -eq 0 ] || return 1
    prefix="$(_koopa_macos_r_prefix)"
    _koopa_activate_prefix "$prefix"
    return 0
}

_koopa_macos_activate_visual_studio_code() { # {{{1
    # """
    # Activate Visual Studio Code.
    # @note Updated 2021-06-14.
    # """
    local x
    [ "$#" -eq 0 ] || return 1
    x='/Applications/Visual Studio Code.app/Contents/Resources/app/bin'
    _koopa_add_to_path_start "$x"
    return 0
}
