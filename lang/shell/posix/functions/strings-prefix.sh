#!/bin/sh

# NOTE Some of these should migrate to Bash library.

_koopa_anaconda_prefix() { # {{{1
    # """
    # Anaconda prefix.
    # @note Updated 2021-05-16.
    # """
    [ "$#" -eq 0 ] || return 1
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
    [ "$#" -eq 0 ] || return 1
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
        elif [ -d "$(_koopa_koopa_prefix)/cellar" ]
        then
            prefix="$(_koopa_koopa_prefix)/cellar"
        fi
    fi
    [ -z "$prefix" ] && prefix="$(_koopa_koopa_prefix)/app"
    _koopa_print "$prefix"
    return 0
}

_koopa_aspera_prefix() { # {{{1
    # """
    # Aspera Connect prefix.
    # @note Updated 2020-11-24.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_opt_prefix)/aspera-connect"
    return 0
}

_koopa_bcbio_tools_prefix() { # {{{1
    # """
    # bcbio-nextgen tools prefix.
    # @note Updated 2021-03-02.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_opt_prefix)/bcbio/tools"
    return 0
}

_koopa_conda_prefix() { # {{{1
    # """
    # Conda prefix.
    # @note Updated 2021-05-25.
    # @seealso conda info --base
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_opt_prefix)/conda"
    return 0
}

_koopa_config_prefix() { # {{{1
    # """
    # Local koopa config directory.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_xdg_config_home)/koopa"
    return 0
}

_koopa_data_disk_link_prefix() { # {{{1
    # """
    # Data disk symlink prefix.
    # @note Updated 2020-07-30.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_is_linux || return 0
    _koopa_print '/n'
    return 0
}

_koopa_distro_prefix() { # {{{1
    # """
    # Operating system distro prefix.
    # @note Updated 2021-05-25.
    # """
    local koopa_prefix os_id prefix
    [ "$#" -eq 0 ] || return 1
    koopa_prefix="$(_koopa_koopa_prefix)"
    os_id="$(_koopa_os_id)"
    if _koopa_is_linux
    then
        prefix="${koopa_prefix}/os/linux/distro/${os_id}"
    else
        prefix="${koopa_prefix}/os/${os_id}"
    fi
    _koopa_print "$prefix"
    return 0
}

_koopa_docker_prefix() { # {{{1
    # """
    # Docker prefix.
    # @note Updated 2020-02-15.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_config_prefix)/docker"
    return 0
}

_koopa_docker_private_prefix() { # {{{1
    # """
    # Private Docker prefix.
    # @note Updated 2020-03-05.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_config_prefix)/docker-private"
    return 0
}

_koopa_doom_emacs_prefix() { # {{{1
    # """
    # Doom Emacs prefix.
    # @note Updated 2021-06-07.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_xdg_data_home)/doom"
    return 0
}

_koopa_dotfiles_prefix() { # {{{1
    # """
    # Koopa system dotfiles prefix.
    # @note Updated 2020-05-05.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_opt_prefix)/dotfiles"
    return 0
}

_koopa_dotfiles_private_prefix() { # {{{1
    # """
    # Private user dotfiles prefix.
    # @note Updated 2020-02-15.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_config_prefix)/dotfiles-private"
    return 0
}

_koopa_emacs_prefix() { # {{{1
    # """
    # Default Emacs prefix.
    # @note Updated 2020-06-29.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "${HOME:?}/.emacs.d"
    return 0
}

_koopa_ensembl_perl_api_prefix() { # {{{1
    # """
    # Ensembl Perl API prefix.
    # @note Updated 2021-05-04.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_opt_prefix)/ensembl-perl-api"
    return 0
}

_koopa_fzf_prefix() { # {{{1
    # """
    # fzf prefix.
    # @note Updated 2020-11-19.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_opt_prefix)/fzf"
    return 0
}

_koopa_go_packages_prefix() { # {{{1
    # """
    # Go packages 'GOPATH', for building from source.
    # @note Updated 2021-05-25.
    #
    # This must be different from 'go root' value.
    #
    # @seealso
    # - go help gopath
    # - go env GOPATH
    # - go env GOROOT
    # - https://golang.org/wiki/SettingGOPATH to set a custom GOPATH
    # """
    local version
    [ "$#" -le 1 ] || return 1
    version="${1:-}"
    if [ -z "$version" ]
    then
        version='latest'
    else
        version="$(_koopa_major_minor_version "$version")"
    fi
    _koopa_print "$(_koopa_opt_prefix)/go-packages/${version}"
    return 0
}

_koopa_go_prefix() { # {{{1
    # """
    # Go prefix.
    # @note Updated 2020-11-19.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_opt_prefix)/go"
    return 0
}

_koopa_homebrew_cellar_prefix() { # {{{1
    # """
    # Homebrew cellar prefix.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -eq 0 ] || return 1
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
    [ "$#" -eq 0 ] || return 1
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
    [ -d "$x" ] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_homebrew_ruby_packages_prefix() { # {{{1
    # """
    # Homebrew Ruby packages (gems) prefix.
    # @note Updated 2021-05-04.
    # """
    local api_version homebrew_prefix prefix
    [ "$#" -eq 0 ] || return 1
    _koopa_is_installed 'brew' 'ruby' || return 0
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
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_koopa_prefix)/include"
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
    [ "$#" -eq 0 ] || return 1
    if [ -n "${JAVA_HOME:-}" ]
    then
        # Allow user to override default.
        prefix="$JAVA_HOME"
    elif [ -x '/usr/libexec/java_home' ]
    then
        # Handle macOS config.
        prefix="$('/usr/libexec/java_home')"
    else
        # Otherwise assume latest OpenJDK.
        # This works on Linux installs, including Docker images.
        prefix="$(_koopa_openjdk_prefix)"
    fi
    _koopa_print "$prefix"
    return 0
}

_koopa_koopa_prefix() { # {{{1
    # """
    # Koopa prefix (home).
    # @note Updated 2020-01-12.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "${KOOPA_PREFIX:?}"
    return 0
}

_koopa_lmod_prefix() { # {{{1
    # """
    # Lmod prefix.
    # @note Updated 2021-01-20.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_opt_prefix)/lmod"
    return 0
}

_koopa_local_data_prefix() { # {{{1
    # """
    # Local user application data prefix.
    # @note Updated 2021-05-25.
    #
    # This is the default app path when koopa is installed per user.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_xdg_data_home)"
    return 0
}

_koopa_make_prefix() { # {{{1
    # """
    # Return the installation prefix to use.
    # @note Updated 2020-08-09.
    # """
    local prefix
    [ "$#" -eq 0 ] || return 1
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
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_refdata_prefix)/msigdb"
    return 0
}

_koopa_monorepo_prefix() { # {{{1
    # """
    # Git monorepo prefix.
    # @note Updated 2020-07-03.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "${HOME:?}/monorepo"
    return 0
}

_koopa_node_packages_prefix() { # {{{1
    # """
    # Node.js (NPM) packages prefix.
    # @note Updated 2021-05-25.
    # """
    local version
    [ "$#" -le 1 ] || return 1
    version="${1:-}"
    if [ -z "$version" ]
    then
        version='latest'
    else
        version="$(_koopa_major_minor_version "$version")"
    fi
    _koopa_print "$(_koopa_opt_prefix)/node-packages/${version}"
    return 0
}

_koopa_openjdk_prefix() { # {{{1
    # """
    # OpenJDK prefix.
    # @note Updated 2020-11-19.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_opt_prefix)/openjdk"
    return 0
}

_koopa_opt_prefix() { # {{{1
    # """
    # Custom application install prefix.
    # @note Updated 2021-05-17.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_koopa_prefix)/opt"
    return 0
}

_koopa_perl_packages_prefix() { # {{{1
    # """
    # Perl site library prefix.
    # @note Updated 2021-05-25.
    #
    # @seealso
    # > perl -V
    # # Inspect the '@INC' variable.
    # """
    local version
    [ "$#" -le 1 ] || return 1
    version="${1:-}"
    if [ -z "$version" ]
    then
        version='latest'
    else
        version="$(_koopa_major_minor_version "$version")"
    fi
    _koopa_print "$(_koopa_opt_prefix)/perl-packages/${version}"
    return 0
}

_koopa_perlbrew_prefix() { # {{{1
    # """
    # Perlbrew prefix.
    # @note Updated 2021-05-25.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_opt_prefix)/perlbrew"
    return 0
}

_koopa_pipx_prefix() { # {{{1
    # """
    # pipx prefix.
    # @note Updated 2021-05-25.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_opt_prefix)/pipx"
    return 0
}

_koopa_prelude_emacs_prefix() { # {{{1
    # """
    # Prelude Emacs prefix.
    # @note Updated 2021-06-07.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_xdg_data_home)/prelude"
    return 0
}

_koopa_pyenv_prefix() { # {{{1
    # """
    # Python pyenv prefix.
    # @note Updated 2021-05-25.
    #
    # See also approach used for rbenv.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_opt_prefix)/pyenv"
    return 0
}

_koopa_python_packages_prefix() { # {{{1
    # """
    # Python site packages library prefix.
    # @note Updated 2021-05-25.
    #
    # This was changed to an unversioned approach in koopa v0.9.
    #
    # @seealso
    # > "$python" -m site
    # """
    local version
    [ "$#" -le 1 ] || return 1
    version="${1:-}"
    if [ -z "$version" ]
    then
        version='latest'
    else
        version="$(_koopa_major_minor_version "$version")"
    fi
    _koopa_print "$(_koopa_opt_prefix)/python-packages/${version}"
    return 0
}

_koopa_r_packages_prefix() { # {{{1
    # """
    # R site library prefix.
    # @note Updated 2021-05-25.
    # """
    local version
    [ "$#" -le 1 ] || return 1
    version="${1:-}"
    if [ -z "$version" ]
    then
        version='latest'
    else
        version="$(_koopa_major_minor_version "$version")"
    fi
    _koopa_print "$(_koopa_opt_prefix)/r-packages/${version}"
    return 0
}

_koopa_rbenv_prefix() { # {{{1
    # """
    # Ruby rbenv prefix.
    # @note Updated 2021-05-25.
    # ""
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_opt_prefix)/rbenv"
    return 0
}

_koopa_refdata_prefix() { # {{{1
    # """
    # Reference data prefix.
    # @note Updated 2020-05-05.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_data_disk_link_prefix)/refdata"
    return 0
}

_koopa_ruby_packages_prefix() { # {{{1
    # """
    # Ruby packags (gems) prefix.
    # @note Updated 2021-05-25.
    # """
    local version
    [ "$#" -le 1 ] || return 1
    version="${1:-}"
    if [ -z "$version" ]
    then
        version='latest'
    else
        version="$(_koopa_major_minor_version "$version")"
    fi
    _koopa_print "$(_koopa_opt_prefix)/ruby-packages/${version}"
    return 0
}

_koopa_rust_packages_prefix() { # {{{1
    # """
    # Rust packages (cargo) install prefix.
    # @note Updated 2021-05-25.
    #
    # See also:
    # - https://github.com/rust-lang/rustup#environment-variables
    # - CARGO_HOME
    # - RUSTUP_HOME
    # """
    local version
    [ "$#" -le 1 ] || return 1
    version="${1:-}"
    if [ -z "$version" ]
    then
        version='latest'
    else
        version="$(_koopa_major_minor_version "$version")"
    fi
    _koopa_print "$(_koopa_opt_prefix)/rust-packages/${version}"
    return 0
}

_koopa_rust_prefix() { # {{{1
    # """
    # Rust (rustup) install prefix.
    # @note Updated 2021-05-25.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_opt_prefix)/rust"
    return 0
}

_koopa_scripts_private_prefix() { # {{{1
    # """
    # Private scripts prefix.
    # @note Updated 2020-02-15.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_config_prefix)/scripts-private"
    return 0
}

_koopa_spacemacs_prefix() { # {{{1
    # """
    # Spacemacs prefix.
    # @note Updated 2021-06-07.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_xdg_data_home)/spacemacs"
    return 0
}

_koopa_spacevim_prefix() { # {{{1
    # """
    # SpaceVim prefix.
    # @note Updated 2021-06-07.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_xdg_data_home)/spacevim"
    return 0
}

_koopa_tests_prefix() { # {{{1
    # """
    # Unit tests prefix.
    # @note Updated 2020-06-24.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_koopa_prefix)/tests"
    return 0
}

_koopa_venv_prefix() { # {{{1
    # """
    # Python venv prefix.
    # @note Updated 2021-04-28.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "$(_koopa_opt_prefix)/virtualenvs"
    return 0
}

_koopa_xdg_cache_home() { # {{{1
    # """
    # XDG cache home.
    # @note Updated 2021-05-20.
    # """
    local x
    [ "$#" -eq 0 ] || return 1
    x="${XDG_CACHE_HOME:-}"
    if [ -z "$x" ]
    then
        x="${HOME:?}/.cache"
    fi
    _koopa_print "$x"
    return 0
}

_koopa_xdg_config_dirs() { # {{{1
    # """
    # XDG config dirs.
    # @note Updated 2021-05-20.
    # """
    local x
    [ "$#" -eq 0 ] || return 1
    x="${XDG_CONFIG_DIRS:-}"
    if [ -z "$x" ] 
    then
        x='/etc/xdg'
    fi
    _koopa_print "$x"
    return 0
}

_koopa_xdg_config_home() { # {{{1
    # """
    # XDG config home.
    # @note Updated 2021-05-20.
    # """
    local x
    [ "$#" -eq 0 ] || return 1
    x="${XDG_CONFIG_HOME:-}"
    if [ -z "$x" ]
    then
        x="${HOME:?}/.config"
    fi
    _koopa_print "$x"
    return 0
}

_koopa_xdg_data_dirs() { # {{{1
    # """
    # XDG data dirs.
    # @note Updated 2021-05-20.
    # """
    local make_prefix x
    [ "$#" -eq 0 ] || return 1
    x="${XDG_DATA_DIRS:-}"
    if [ -z "$x" ]
    then
        make_prefix="$(_koopa_make_prefix)"
        x="${make_prefix}/share:/usr/share"
    fi
    _koopa_print "$x"
    return 0
}

_koopa_xdg_data_home() { # {{{1
    # """
    # XDG data home.
    # @note Updated 2021-05-20.
    # """
    local x
    [ "$#" -eq 0 ] || return 1
    x="${XDG_DATA_HOME:-}"
    if [ -z "$x" ]
    then
        x="${HOME:?}/.local/share"
    fi
    _koopa_print "$x"
    return 0
}

_koopa_xdg_local_home() { # {{{1
    # """
    # XDG local installation home.
    # @note Updated 2021-05-20.
    #
    # Not intended to be configurable with a global variable.
    #
    # @seealso
    # - https://www.freedesktop.org/software/systemd/man/file-hierarchy.html
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print "${HOME:?}/.local"
    return 0
}

_koopa_xdg_runtime_dir() { # {{{1
    # """
    # XDG runtime dir.
    # @note Updated 2021-05-20.
    #
    # Specification:
    # - Can only exist for the duration of the user's login.
    # - Updated every 6 hours or set sticky bit if persistence is desired.
    # - Should not store large files as it may be mounted as a tmpfs.
    # """
    local user_id x
    [ "$#" -eq 0 ] || return 1
    x="${XDG_RUNTIME_DIR:-}"
    if [ -z "$x" ]
    then
        user_id="$(_koopa_user_id)"
        x="/run/user/${user_id}"
        if _koopa_is_macos
        then
            x="/tmp${x}"
        fi
    fi
    _koopa_print "$x"
    return 0
}
