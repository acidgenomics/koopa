#!/bin/sh

_koopa_anaconda_prefix() { # {{{1
    # """
    # Anaconda prefix.
    # @note Updated 2021-05-16.
    # """
    _koopa_print "$(_koopa_opt_prefix)/conda"
    return 0
}

_koopa_app_prefix() { # {{{1
    # """
    # Application prefix.
    # @note Updated 2021-02-15.
    #
    # Previously referred to as "cellar", prior to v0.9.
    #
    # Recommended to keep on a local mount.
    # """
    local prefix
    prefix="${KOOPA_APP_PREFIX:-}"
    # Don't allow this prefix to match the opt prefix.
    if [ -n "$prefix" ] && [ "$prefix" = "$(_koopa_opt_prefix)" ]
    then
        prefix=''
    fi
    # Provide fallback support for existing installs using "cellar".
    # Otherwise, use "app" by default.
    if [ -z "$prefix" ] && _koopa_is_linux
    then
        if [ -d "$(_koopa_make_prefix)/cellar" ]
        then
            prefix="$(_koopa_make_prefix)/cellar"
        elif [ -d "$(_koopa_prefix)/cellar" ]
        then
            prefix="$(_koopa_prefix)/cellar"
        fi
    fi
    [ -z "$prefix" ] && prefix="$(_koopa_prefix)/app"
    _koopa_print "$prefix"
    return 0
}

_koopa_aspera_prefix() { # {{{1
    # """
    # Aspera Connect prefix.
    # @note Updated 2020-11-24.
    # """
    _koopa_print "$(_koopa_opt_prefix)/aspera-connect"
    return 0
}

_koopa_bcbio_tools_prefix() { # {{{1
    # """
    # bcbio-nextgen tools prefix.
    # @note Updated 2021-03-02.
    # """
    _koopa_is_linux || return 0
    _koopa_print "$(_koopa_opt_prefix)/bcbio/tools"
    return 0
}

_koopa_conda_prefix() { # {{{1
    # """
    # Conda prefix.
    # @note Updated 2020-11-19.
    # @seealso conda info --base
    # """
    local prefix
    if [ -n "${CONDA_EXE:-}" ]
    then
        prefix="$(_koopa_parent_dir -n 2 "$CONDA_EXE")"
    else
        prefix="$(_koopa_opt_prefix)/conda"
    fi
    _koopa_print "$prefix"
    return 0
}

_koopa_config_prefix() { # {{{1
    # """
    # Local koopa config directory.
    # @note Updated 2020-07-01.
    # """
    local prefix
    prefix="${XDG_CONFIG_HOME:-}"
    [ -z "$prefix" ] && prefix="${HOME:?}/.config"
    _koopa_print "${prefix}/koopa"
    return 0
}

_koopa_data_disk_link_prefix() { # {{{1
    # """
    # Data disk symlink prefix.
    # @note Updated 2020-07-30.
    # """
    _koopa_is_linux || return 0
    _koopa_print '/n'
    return 0
}

_koopa_distro_prefix() { # {{{1
    # """
    # Operating system distro prefix.
    # @note Updated 2020-11-12.
    # """
    local prefix
    if _koopa_is_linux
    then
        prefix="$(_koopa_prefix)/os/linux/distro/$(_koopa_os_id)"
    else
        prefix="$(_koopa_prefix)/os/$(_koopa_os_id)"
    fi
    _koopa_print "$prefix"
    return 0
}

_koopa_docker_prefix() { # {{{1
    # """
    # Docker prefix.
    # @note Updated 2020-02-15.
    # """
    _koopa_print "$(_koopa_config_prefix)/docker"
    return 0
}

_koopa_docker_private_prefix() { # {{{1
    # """
    # Private Docker prefix.
    # @note Updated 2020-03-05.
    # """
    _koopa_print "$(_koopa_config_prefix)/docker-private"
    return 0
}

_koopa_dotfiles_prefix() { # {{{1
    # """
    # Koopa system dotfiles prefix.
    # @note Updated 2020-05-05.
    # """
    _koopa_print "$(_koopa_opt_prefix)/dotfiles"
    return 0
}

_koopa_dotfiles_private_prefix() { # {{{1
    # """
    # Private user dotfiles prefix.
    # @note Updated 2020-02-15.
    # """
    _koopa_print "$(_koopa_config_prefix)/dotfiles-private"
    return 0
}

_koopa_emacs_prefix() { # {{{1
    # """
    # Default Emacs prefix.
    # @note Updated 2020-06-29.
    # """
    _koopa_print "${HOME:?}/.emacs.d"
    return 0
}

_koopa_ensembl_perl_api_prefix() { # {{{1
    # """
    # Ensembl Perl API prefix.
    # @note Updated 2021-05-04.
    # """
    _koopa_print "$(_koopa_opt_prefix)/ensembl-perl-api"
    return 0
}

_koopa_fzf_prefix() { # {{{1
    # """
    # fzf prefix.
    # @note Updated 2020-11-19.
    # """
    _koopa_print "$(_koopa_opt_prefix)/fzf"
    return 0
}

_koopa_go_packages_prefix() { # {{{1
    # """
    # Go packages 'GOPATH', for building from source.
    # @note Updated 2021-05-19.
    #
    # This must be different from 'go root' value.
    #
    # @seealso
    # - go help gopath
    # - go env GOPATH
    # - go env GOROOT
    # - https://golang.org/wiki/SettingGOPATH to set a custom GOPATH
    # """
    local prefix version
    prefix="${GOPATH:-}"
    version="${1:-}"
    if [ -z "$prefix" ]
    then
        if [ -z "$version" ]
        then
            version='rolling'
        fi
        prefix="$(_koopa_opt_prefix)/go-packages/${version}"
    fi
    _koopa_print "$prefix"
    return 0
}

_koopa_go_prefix() { # {{{1
    # """
    # Go prefix.
    # @note Updated 2020-11-19.
    # """
    _koopa_print "$(_koopa_opt_prefix)/go"
    return 0
}

_koopa_homebrew_cellar_prefix() { # {{{1
    # """
    # Homebrew cellar prefix.
    # @note Updated 2020-07-01.
    # """
    _koopa_print "$(_koopa_homebrew_prefix)/Cellar"
    return 0
}

_koopa_homebrew_prefix() { # {{{1
    # """
    # Homebrew prefix.
    # @note Updated 2021-04-30.
    #
    # @seealso https://brew.sh/
    # """
    local arch x
    x="${HOMEBREW_PREFIX:-}"
    if [ -z "$x" ]
    then
        if _koopa_is_installed brew
        then
            x="$(brew --prefix)"
        elif _koopa_is_macos
        then
            arch="$(_koopa_arch)"
            case "$arch" in
                arm*)
                    x='/opt/homebrew'
                    ;;
                x86*)
                    x='/usr/local'
                    ;;
            esac
        elif _koopa_is_linux
        then
            x='/home/linuxbrew/.linuxbrew'
        fi
    fi
    [ -n "$x" ] || return 0
    _koopa_print "$x"
    return 0
}

_koopa_homebrew_ruby_packages_prefix() { # {{{1
    # """
    # Homebrew Ruby packages (gems) prefix.
    # @note Updated 2021-05-04.
    # """
    local api_version homebrew_prefix prefix
    _koopa_is_installed brew ruby || return 0
    homebrew_prefix="$(_koopa_homebrew_prefix)"
    api_version="$(_koopa_ruby_api_version)"
    prefix="${homebrew_prefix}/lib/ruby/gems/${api_version}"
    _koopa_print "$prefix"
    return 0
}

_koopa_include_prefix() { # {{{1
    # """
    # Koopa system includes prefix.
    # @note Updated 2020-07-30.
    # """
    _koopa_print "$(_koopa_prefix)/include"
    return 0
}

_koopa_java_prefix() { # {{{1
    # """
    # Java prefix.
    # @note Updated 2021-05-05.
    #
    # See also:
    # - https://www.mkyong.com/java/
    #       how-to-set-java_home-environment-variable-on-mac-os-x/
    # - https://stackoverflow.com/questions/22290554
    # """
    local prefix
    if [ -n "${JAVA_HOME:-}" ]
    then
        # Allow user to override default.
        prefix="$JAVA_HOME"
    elif [ -x '/usr/libexec/java_home' ]
    then
        # Handle macOS config.
        prefix="$(/usr/libexec/java_home)"
    else
        # Otherwise assume latest OpenJDK.
        # This works on Linux installs, including Docker images.
        prefix="$(_koopa_openjdk_prefix)"
    fi
    _koopa_print "$prefix"
    return 0
}

_koopa_lmod_prefix() { # {{{1
    # """
    # Lmod prefix.
    # @note Updated 2021-01-20.
    # """
    _koopa_print "$(_koopa_opt_prefix)/lmod"
    return 0
}

_koopa_local_data_prefix() { # {{{1
    # """
    # Local user application data prefix.
    # @note Updated 2020-12-31.
    #
    # This is the default app path when koopa is installed per user.
    # """
    local prefix
    prefix="${XDG_DATA_HOME:-}"
    [ -z "$prefix" ] && prefix="${HOME:?}/.local/share"
    _koopa_print "$prefix"
    return 0
}

_koopa_make_prefix() { # {{{1
    # """
    # Return the installation prefix to use.
    # @note Updated 2020-08-09.
    # """
    local prefix
    if [ -n "${KOOPA_MAKE_PREFIX:-}" ]
    then
        prefix="$KOOPA_MAKE_PREFIX"
    elif _koopa_is_shared_install
    then
        prefix='/usr/local'
    else
        prefix="${HOME}/.local"
    fi
    _koopa_print "$prefix"
    return 0
}

_koopa_msigdb_prefix() { # {{{1
    # """
    # MSigDB prefix.
    # @note Updated 2020-05-05.
    # """
    _koopa_print "$(_koopa_refdata_prefix)/msigdb"
    return 0
}

_koopa_monorepo_prefix() { # {{{1
    # """
    # Git monorepo prefix.
    # @note Updated 2020-07-03.
    # """
    _koopa_print "${HOME:?}/monorepo"
    return 0
}

_koopa_openjdk_prefix() { # {{{1
    # """
    # OpenJDK prefix.
    # @note Updated 2020-11-19.
    # """
    _koopa_print "$(_koopa_opt_prefix)/openjdk"
    return 0
}

_koopa_opt_prefix() { # {{{1
    # """
    # Custom application install prefix.
    # @note Updated 2021-05-17.
    # """
    _koopa_print "$(_koopa_prefix)/opt"
    return 0
}

_koopa_perl_packages_prefix() { # {{{1
    # """
    # Perl site library prefix.
    # @note Updated 2021-05-19.
    #
    # @seealso
    # > perl -V
    # # Inspect the '@INC' variable.
    # """
    local major_minor_version version
    version="${1:-}"
    if [ -z "$version" ]
    then
        version="$(_koopa_variable 'perl')"
    fi
    major_minor_version="$(_koopa_major_minor_version "$version")"
    _koopa_print "$(_koopa_opt_prefix)/perl-packages/${major_minor_version}"
    return 0
}

_koopa_perlbrew_prefix() { # {{{1
    # """
    # Perlbrew prefix.
    # @note Updated 2020-12-31.
    # """
    local prefix
    prefix="${PERLBREW_ROOT:-}"
    [ -z "$prefix" ] && prefix="$(_koopa_opt_prefix)/perlbrew"
    _koopa_print "$prefix"
    return 0
}

_koopa_pipx_prefix() { # {{{1
    # """
    # pipx prefix.
    # @note Updated 2020-12-31.
    # """
    local prefix
    prefix="${PIPX_HOME:-}"
    [ -z "$prefix" ] && prefix="$(_koopa_opt_prefix)/pipx"
    _koopa_print "$prefix"
    return 0
}

_koopa_prefix() { # {{{1
    # """
    # Koopa prefix (home).
    # @note Updated 2020-01-12.
    # """
    _koopa_print "${KOOPA_PREFIX:?}"
    return 0
}

_koopa_pyenv_prefix() { # {{{1
    # """
    # Python pyenv prefix.
    # @note Updated 2020-12-31.
    #
    # See also approach used for rbenv.
    # """
    local prefix
    prefix="${PYENV_ROOT:-}"
    [ -z "$prefix" ] && prefix="$(_koopa_opt_prefix)/pyenv"
    _koopa_print "$prefix"
    return 0
}

_koopa_python_packages_prefix() { # {{{1
    # """
    # Python site packages library prefix.
    # @note Updated 2021-05-19.
    #
    # This was changed to an unversioned approach in koopa v0.9.
    #
    # @seealso
    # > "$python" -m site
    # """
    local version
    version="${1:-}"
    if [ -z "$version" ]
    then
        version="$(_koopa_variable 'python')"
    fi
    major_minor_version="$(_koopa_major_minor_version "$version")"
    _koopa_print "$(_koopa_opt_prefix)/python-packages/${major_minor_version}"
    return 0
}

_koopa_python_system_packages_prefix() { # {{{1
    # """
    # Python system site packages library prefix.
    # @note Updated 2021-05-04.
    # """
    local python x
    python="${1:-}"
    [ -z "$python" ] && python="$(_koopa_python)"
    _koopa_is_installed "$python" || return 0
    x="$("$python" -c "import site; print(site.getsitepackages()[0])")"
    _koopa_print "$x"
    return 0
}

_koopa_r_packages_prefix() { # {{{1
    # """
    # R site library prefix.
    # @note Updated 2021-05-19.
    # """
    local major_minor_version version
    version="${1:?}"
    if [ -z "$version" ]
    then
        version="$(_koopa_variable 'r')"
    fi
    major_minor_version="$(_koopa_major_minor_version "$version")"
    _koopa_print "$(_koopa_opt_prefix)/r-packages/${major_minor_version}"
    return 0
}

_koopa_rbenv_prefix() { # {{{1
    # """
    # Ruby rbenv prefix.
    # @note Updated 2020-12-31.
    # ""
    local prefix
    prefix="${RBENV_ROOT:-}"
    [ -z "$prefix" ] && prefix="$(_koopa_opt_prefix)/rbenv"
    _koopa_print "$prefix"
    return 0
}

_koopa_refdata_prefix() { # {{{1
    # """
    # Reference data prefix.
    # @note Updated 2020-05-05.
    # """
    _koopa_print "$(_koopa_data_disk_link_prefix)/refdata"
    return 0
}

_koopa_ruby_packages_prefix() { # {{{1
    # """
    # Ruby packags (gems) prefix.
    # @note Updated 2021-05-19.
    # """
    local major_minor_version prefix version
    prefix="${GEM_HOME:-}"
    version="${1:-}"
    if [ -z "$prefix" ]
    then
        if [ -z "$version" ]
        then
            version="$(_koopa_variable 'ruby')"
        fi
        major_minor_version="$(_koopa_major_minor_version "$version")"
        prefix="$(_koopa_opt_prefix)/ruby-packages/${major_minor_version}"
    fi
    _koopa_print "$prefix"
    return 0
}

_koopa_rust_packages_prefix() { # {{{1
    # """
    # Rust packages (cargo) install prefix.
    # @note Updated 2021-05-19.
    #
    # See also:
    # - https://github.com/rust-lang/rustup#environment-variables
    # - CARGO_HOME
    # - RUSTUP_HOME
    # """
    local prefix version
    prefix="${CARGO_HOME:-}"
    version="${1:-}"
    if [ -z "$prefix" ]
    then
        if [ -z "$version" ]
        then
            version='rolling'
        fi
        prefix="$(_koopa_opt_prefix)/rust-packages/${version}"
    fi
    _koopa_print "$prefix"
    return 0
}

_koopa_rust_prefix() { # {{{1
    # """
    # Rust (rustup) install prefix.
    # @note Updated 2021-05-06.
    # """
    local prefix
    prefix="${RUSTUP_HOME:-}"
    [ -z "$prefix" ] && prefix="$(_koopa_opt_prefix)/rust"
    _koopa_print "$prefix"
    return 0
}

_koopa_scripts_private_prefix() { # {{{1
    # """
    # Private scripts prefix.
    # @note Updated 2020-02-15.
    # """
    _koopa_print "$(_koopa_config_prefix)/scripts-private"
    return 0
}

_koopa_tests_prefix() { # {{{1
    # """
    # Unit tests prefix.
    # @note Updated 2020-06-24.
    # """
    _koopa_print "$(_koopa_prefix)/tests"
    return 0
}

_koopa_venv_prefix() { # {{{1
    # """
    # Python venv prefix.
    # @note Updated 2021-04-28.
    # """
    _koopa_print "$(_koopa_opt_prefix)/virtualenvs"
    return 0
}
