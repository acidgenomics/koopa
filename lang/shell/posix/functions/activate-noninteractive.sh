#!/bin/sh

_koopa_activate_aspera() { # {{{1
    # """
    # Include Aspera Connect binaries in PATH, if defined.
    # @note Updated 2020-06-30.
    # """
    _koopa_activate_prefix "$(_koopa_aspera_prefix)/latest"
    return 0
}

_koopa_activate_bcbio() { # {{{1
    # """
    # Activate bcbio-nextgen tool binaries.
    # @note Updated 2021-03-02.
    #
    # Attempt to locate bcbio installation automatically on supported platforms.
    #
    # Exporting at the end of PATH so we don't mask gcc or R.
    # This is particularly important to avoid unexpected compilation issues
    # due to compilers in conda masking the system versions.
    # """
    local prefix
    _koopa_is_linux || return 0
    _koopa_is_installed bcbio_nextgen.py && return 0
    prefix="$(_koopa_bcbio_tools_prefix)"
    [ -d "$prefix" ] || return 0
    _koopa_add_to_path_end "${prefix}/bin"
    unset -v PYTHONHOME PYTHONPATH
    return 0
}

_koopa_activate_conda() { # {{{1
    # """
    # Activate conda.
    # @note Updated 2021-05-16.
    # """
    local anaconda_prefix conda_prefix name nounset prefix
    prefix="${1:-}"
    # Prefer Miniconda over Anaconda by default, if both are installed.
    if [ -z "$prefix" ]
    then
        anaconda_prefix="$(_koopa_anaconda_prefix)"
        conda_prefix="$(_koopa_conda_prefix)"
        if [ -d "$conda_prefix" ]
        then
            prefix="$conda_prefix"
        elif [ -d "$anaconda_prefix" ]
        then
            prefix="$anaconda_prefix"
        fi
    fi
    [ -d "$prefix" ] || return 0
    name="${2:-base}"
    script="${prefix}/bin/activate"
    [ -r "$script" ] || return 0
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    # shellcheck source=/dev/null
    . "$script"
    # Ensure base environment gets deactivated by default.
    if [ "$name" = 'base' ]
    then
        # Don't use the full conda path here; will return config error.
        conda deactivate
    fi
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_dash_extras() { # {{{1
    # """
    # Extra configuration options for Dash shell.
    # @note Updated 2021-05-07.
    # """
    export PS1='# '
    return 0
}

_koopa_activate_emacs() { # {{{1
    # """
    # Activate Emacs.
    # @note Updated 2020-06-30.
    # """
    _koopa_activate_prefix "${HOME}/.emacs.d"
    return 0
}

_koopa_activate_ensembl_perl_api() { # {{{1
    # """
    # Activate Ensembl Perl API.
    # @note Updated 2020-12-31.
    #
    # Note that this currently requires Perl 5.26.
    # > perlbrew switch perl-5.26
    # """
    local prefix
    prefix="$(_koopa_ensembl_perl_api_prefix)"
    [ -d "$prefix" ] || return 0
    _koopa_activate_prefix "${prefix}/ensembl-git-tools"
    PERL5LIB="${PERL5LIB}:${prefix}/bioperl-1.6.924"
    PERL5LIB="${PERL5LIB}:${prefix}/ensembl/modules"
    PERL5LIB="${PERL5LIB}:${prefix}/ensembl-compara/modules"
    PERL5LIB="${PERL5LIB}:${prefix}/ensembl-variation/modules"
    PERL5LIB="${PERL5LIB}:${prefix}/ensembl-funcgen/modules"
    export PERL5LIB
    return 0
}

_koopa_activate_gcc_colors() { # {{{1
    # """
    # Activate GCC colors.
    # @note Updated 2020-06-30.
    # """
    # Colored GCC warnings and errors.
    [ -n "${GCC_COLORS:-}" ] && return 0
    export GCC_COLORS="caret=01;32:error=01;31:locus=01:note=01;36:\
quote=01:warning=01;35"
    return 0
}

_koopa_activate_gnu() { # {{{1
    # """
    # Activate GNU utilities.
    # @note Updated 2021-05-21.
    #
    # Creates hardened interactive aliases for GNU coreutils.
    #
    # These aliases get unaliased inside of koopa scripts, and they should only
    # apply to interactive use at the command prompt.
    #
    # macOS ships with BSD coreutils, which don't support all GNU options.
    # """
    local cp harden_coreutils ln mkdir mv opt_prefix rm
    if _koopa_is_linux
    then
        harden_coreutils=1
        cp='cp'
        ln='ln'
        mkdir='mkdir'
        mv='mv'
        rm='rm'
    elif _koopa_is_macos
    then
        _koopa_is_installed brew || return 0
        opt_prefix="$(_koopa_homebrew_prefix)/opt"
        if [ -d "${opt_prefix}/coreutils" ]
        then
            harden_coreutils=1
            # These are hardened utils where we are changing default args.
            cp='gcp'
            ln='gln'
            mkdir='gmkdir'
            mv='gmv'
            rm='grm'
            # Standardize using GNU variants by default.
            alias basename='gbasename'
            alias chgrp='gchgrp'
            alias chmod='gchmod'
            alias chown='gchown'
            alias cut='gcut'
            alias date='gdate'
            alias dirname='gdirname'
            alias du='gdu'
            alias head='ghead'
            alias readlink='greadlink'
            alias realpath='grealpath'
            alias sort='gsort'
            alias stat='gstat'
            alias tail='gtail'
            alias tee='gtee'
            alias tr='gtr'
            alias uname='guname'
        else
            _koopa_alert_not_installed 'Homebrew coreutils'
            harden_coreutils=0
        fi
        if [ -d "${opt_prefix}/findutils" ]
        then
            alias find='gfind'
            alias xargs='gxargs'
        else
            _koopa_alert_not_installed 'Homebrew findutils'
        fi
        if [ -d "${opt_prefix}/gawk" ]
        then
            alias awk='gawk'
        else
            _koopa_alert_not_installed 'Homebrew gawk'
        fi
        if [ -d "${opt_prefix}/gnu-sed" ]
        then
            alias sed='gsed'
        else
            _koopa_alert_not_installed 'Homebrew gnu-sed'
        fi
        if [ -d "${opt_prefix}/gnu-tar" ]
        then
            alias tar='gtar'
        else
            _koopa_alert_not_installed 'Homebrew gnu-tar'
        fi
        if [ -d "${opt_prefix}/grep" ]
        then
            alias grep='ggrep'
        else
            _koopa_alert_not_installed 'Homebrew grep'
        fi
        if [ -d "${opt_prefix}/make" ]
        then
            alias make='gmake'
        else
            _koopa_alert_not_installed 'Homebrew make'
        fi
        if [ -d "${opt_prefix}/man-db" ]
        then
            alias man='gman'
        else
            _koopa_alert_not_installed 'Homebrew man-db'
        fi
    fi
    if [ "$harden_coreutils" -eq 1 ]
    then
        # The '--archive' flag seems to have issues on some file systems.
        # shellcheck disable=SC2139
        alias cp="${cp} --interactive --recursive" # -i
        # shellcheck disable=SC2139
        alias ln="${ln} --interactive --no-dereference --symbolic" # -ins
        # shellcheck disable=SC2139
        alias mkdir="${mkdir} --parents" # -p
        # shellcheck disable=SC2139
        alias mv="${mv} --interactive" # -i
        # Problematic on some file systems: --dir --preserve-root
        # Don't enable '--recursive' here by default, so we don't accidentally
        # nuke an important directory.
        # shellcheck disable=SC2139
        alias rm="${rm} --interactive=once" # -I
    fi
    return 0
}

_koopa_activate_go() { # {{{1
    # """
    # Activate Go.
    # @note Updated 2021-05-05.
    # """
    local prefix
    prefix="$(_koopa_go_prefix)"
    [ -d "$prefix" ] && _koopa_activate_prefix "$prefix"
    _koopa_is_installed go || return 0
    [ -z "${GOPATH:-}" ] && GOPATH="$(_koopa_go_packages_prefix)"
    export GOPATH
    return 0
}

_koopa_activate_homebrew() { # {{{1
    # """
    # Activate Homebrew.
    # @note Updated 2021-04-30.
    # """
    local prefix
    prefix="$(_koopa_homebrew_prefix)"
    ! _koopa_is_installed brew && _koopa_activate_prefix "$prefix"
    _koopa_is_installed brew || return 0
    export HOMEBREW_INSTALL_CLEANUP=1
    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_AUTO_UPDATE=1
    export HOMEBREW_PREFIX="$prefix"
    # Stopgap fix for TLS SSL issues with some Homebrew casks.
    # This can error when updating libidn2.
    # > if [ -x "${prefix}/opt/curl/bin/curl" ]
    # > then
    # >     export HOMEBREW_FORCE_BREWED_CURL=1
    # > fi
    if _koopa_is_macos
    then
        export HOMEBREW_CASK_OPTS='--no-binaries --no-quarantine'
        _koopa_activate_homebrew_prefix 'curl' 'ruby'
        _koopa_activate_homebrew_cask_google_cloud_sdk
        _koopa_activate_homebrew_cask_gpg_suite
        _koopa_activate_homebrew_cask_julia
        _koopa_activate_homebrew_cask_r
    fi
    return 0
}

_koopa_activate_homebrew_cask_google_cloud_sdk() { # {{{1
    # """
    # Activate Homebrew Google Cloud SDK.
    # @note Updated 2021-04-25.
    # """
    local prefix
    prefix="$(_koopa_homebrew_prefix)"
    prefix="${prefix}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
    _koopa_activate_prefix "$prefix"
    # Alternate (slower) approach that enables autocompletion.
    # > [ -d "$prefix" ] || return 0
    # > local shell
    # > shell="$(_koopa_shell_name)"
    # > # shellcheck source=/dev/null
    # > [ -f "${prefix}/path.${shell}.inc" ] && \
    # >     . "${prefix}/path.${shell}.inc"
    # > # shellcheck source=/dev/null
    # > [ -f "${prefix}/completion.${shell}.inc" ] && \
    # >     . "${prefix}/completion.${shell}.inc"
    return 0
}

_koopa_activate_homebrew_cask_gpg_suite() { # {{{1
    # """
    # Activate MacGPG (gpg-suite) Homebrew cask.
    # @note Updated 2021-04-22.
    #
    # This code shouldn't be necessary to run at startup, since MacGPG2
    # should be configured at '/private/etc/paths.d/MacGPG2' automatically.
    # """
    _koopa_activate_prefix '/usr/local/MacGPG2'
    return 0
}

# FIXME Can we do this without using the variable?
_koopa_activate_homebrew_cask_julia() { # {{{1
    # """
    # Activate Julia Homebrew cask.
    # @note Updated 2021-04-25.
    # """
    local prefix version
    version="$(_koopa_variable 'julia')"  # FIXME Take this out...
    version="$(_koopa_major_minor_version "$version")"
    prefix="/Applications/Julia-${version}.app/Contents/Resources/julia"
    _koopa_activate_prefix "$prefix"
    return 0
}

_koopa_activate_homebrew_cask_r() { # {{{1
    # """
    # Activate R Homebrew cask.
    # @note Updated 2021-05-25.
    # """
    local prefix version
    version='Current'
    prefix="/Library/Frameworks/R.framework/Versions/${version}/Resources"
    _koopa_activate_prefix "$prefix"
    return 0
}

_koopa_activate_homebrew_gnu_prefix() { # {{{1
    # """
    # Activate a Homebrew cellar-only GNU program.
    # @note Updated 2021-03-31.
    #
    # Linked using 'g' prefix by default.
    #
    # Note that libtool is always prefixed with 'g', even in 'opt/'.
    #
    # @seealso:
    # - brew info binutils
    # - brew info coreutils
    # - brew info findutils
    # - brew info gnu-sed
    # - brew info gnu-tar
    # - brew info gnu-time
    # - brew info gnu-units
    # - brew info gnu-which
    # - brew info grep
    # - brew info libtool
    # - brew info make
    # """
    local homebrew_prefix name prefix
    homebrew_prefix="$(_koopa_homebrew_prefix)"
    for name in "$@"
    do
        prefix="${homebrew_prefix}/opt/${name}/libexec"
        [ -d "$prefix" ] || continue
        _koopa_add_to_path_start "${prefix}/gnubin"
        _koopa_add_to_manpath_start "${prefix}/gnuman"
    done
    return 0
}

_koopa_activate_homebrew_keg_only() { # {{{1
    # """
    # Activate Homebrew GNU utilities.
    # @note Updated 2021-05-20.
    #
    # Note that these mask some macOS system utilities and are not recommended
    # to be included in system shell activation. These are OK to activate
    # inside of Bash scripts.
    #
    # Consider including here:
    # - icu4c
    # - ncurses
    # - sqlite
    # - texinfo
    # """
    _koopa_is_installed 'brew' || return 0
    _koopa_activate_homebrew_gnu_prefix \
        'coreutils' \
        'findutils' \
        'gnu-sed' \
        'gnu-tar' \
        'gnu-units' \
        'gnu-which' \
        'grep' \
        'make'
    _koopa_activate_homebrew_prefix \
        'bc' \
        'binutils' \
        'curl'
    _koopa_activate_homebrew_libexec_prefix 'man-db'
    return 0
}

_koopa_activate_homebrew_libexec_prefix() { # {{{1
    # """
    # Activate a Homebrew cellar-only program.
    # @note Updated 2021-03-31.
    # """
    local homebrew_prefix name prefix
    homebrew_prefix="$(_koopa_homebrew_prefix)"
    for name in "$@"
    do
        prefix="${homebrew_prefix}/opt/${name}/libexec"
        [ -d "$prefix" ] || continue
        _koopa_activate_prefix "$prefix"
    done
    return 0
}

_koopa_activate_homebrew_prefix() { # {{{1
    # """
    # Activate a Homebrew cellar-only program.
    # @note Updated 2021-03-31.
    # """
    local homebrew_prefix name prefix
    homebrew_prefix="$(_koopa_homebrew_prefix)"
    for name in "$@"
    do
        prefix="${homebrew_prefix}/opt/${name}"
        [ -d "$prefix" ] || continue
        _koopa_activate_prefix "$prefix"
    done
    return 0
}

_koopa_activate_homebrew_python() { # {{{1
    # """
    # Activate Homebrew Python.
    # @note Updated 2020-10-27.
    # """
    local version
    version="$(_koopa_major_minor_version "$(_koopa_variable 'python')")"
    _koopa_activate_homebrew_prefix "python@${version}"
    return 0
}

_koopa_activate_homebrew_ruby_packages() { # {{{1
    # """
    # Activate Homebrew Ruby packages (gems).
    # @note Updated 2020-12-31.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/ruby.rb
    # - https://stackoverflow.com/questions/12287882/
    # """
    _koopa_activate_prefix "$(_koopa_homebrew_ruby_packages_prefix)"
    return 0
}

_koopa_activate_koopa_paths() { # {{{1
    # """
    # Automatically configure koopa PATH and MANPATH.
    # @note Updated 2021-01-19.
    # """
    local config_prefix distro_prefix koopa_prefix linux_prefix shell
    koopa_prefix="$(_koopa_prefix)"
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

_koopa_activate_llvm() { # {{{1
    # """
    # Activate LLVM config.
    # @note Updated 2021-05-24.
    # """
    LLVM_CONFIG="$(_koopa_locate_llvm_config)"
    export LLVM_CONFIG
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
    shell="$(_koopa_shell_name)"
    case "$shell" in
        bash)
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
    _koopa_activate_prefix "$(_koopa_xdg_local_home)"
    _koopa_add_to_path_start "${HOME:?}/bin"
    return 0
}

_koopa_activate_nextflow() { # {{{1
    # """
    # Activate Nextflow configuration.
    # @note Updated 2020-07-21.
    # @seealso
    # - https://github.com/nf-core/smrnaseq/blob/master/docs/usage.md
    # """
    [ -z "${NXF_OPTS:-}" ] || return 0
    export NXF_OPTS='-Xms1g -Xmx4g'
    return 0
}

_koopa_activate_node() { # {{{1
    # """
    # Activate Node.js (and NPM).
    # @note Updated 2021-05-25.
    # """
    local prefix
    prefix="$(_koopa_node_packages_prefix)"
    [ -d "$prefix" ] || return 0
    _koopa_activate_prefix "$prefix"
    export NPM_CONFIG_PREFIX="$prefix"
    return 0
}

_koopa_activate_openjdk() { # {{{1
    # """
    # Activate OpenJDK.
    # @note Updated 2021-05-06.
    #
    # Use Homebrew instead to manage on macOS.
    #
    # We're using a symlink approach here to manage versions.
    # """
    local prefix
    _koopa_is_linux || return 0
    prefix="$(_koopa_openjdk_prefix)"
    [ -d "$prefix" ] || return 0
    _koopa_activate_prefix "$prefix"
    return 0
}

_koopa_activate_perl_packages() { # {{{1
    # """
    # Activate Perl local library.
    # @note Updated 2021-05-25.
    # @seealso
    # - brew info perl
    # """
    local prefix
    prefix="$(_koopa_perl_packages_prefix)"
    [ -d "$prefix" ] || return 0
    _koopa_is_installed perl || return 0
    # NOTE This step may error/warn if new shell is activated while Perl
    # packages are installing.
    eval "$( \
        perl \
            "-I${prefix}/lib/perl5" \
            "-Mlocal::lib=${prefix}" \
    )"
    _koopa_activate_prefix "$prefix"
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
    [ -n "${PERLBREW_ROOT:-}" ] && return 0
    ! _koopa_is_installed perlbrew || return 0
    shell="$(_koopa_shell_name)"
    case "$shell" in
        bash|zsh)
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
    # @note Updated 2021-03-25.
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
    local arch homebrew_prefix make_prefix sys_pkg_config
    [ -n "${PKG_CONFIG_PATH:-}" ] && return 0
    make_prefix="$(_koopa_make_prefix)"
    sys_pkg_config='/usr/bin/pkg-config'
    if _koopa_is_installed "$sys_pkg_config"
    then
        PKG_CONFIG_PATH="$("$sys_pkg_config" --variable pc_path pkg-config)"
    fi
    _koopa_add_to_pkg_config_path_start \
        "${make_prefix}/share/pkgconfig" \
        "${make_prefix}/lib/pkgconfig" \
        "${make_prefix}/lib64/pkgconfig"
    if _koopa_is_linux
    then
        arch="$(_koopa_arch)"
        _koopa_add_to_pkg_config_path_start \
            "${make_prefix}/lib/${arch}-linux-gnu/pkgconfig"
    fi
    return 0
}

_koopa_activate_prefix() { # {{{1
    # """
    # Automatically configure 'PATH', 'PKG_CONFIG_PATH' and 'MANPATH' for a
    # specified prefix.
    # @note Updated 2021-05-10.
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
            "${prefix}/lib/pkgconfig"
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

_koopa_activate_python_packages() { # {{{1
    # """
    # Activate Python site packages library.
    # @note Updated 2021-05-04.
    #
    # This ensures that 'bin' will be added to PATH, which is useful when
    # installing via pip with '--target' flag.
    # """
    _koopa_activate_prefix "$(_koopa_python_packages_prefix)"
    return 0
}

_koopa_activate_python_startup() { # {{{1
    # """
    # Activate Python startup configuration.
    # @note Updated 2020-07-13.
    # @seealso
    # - https://stackoverflow.com/questions/33683744/
    # """
    local file
    file="${HOME}/.pyrc"
    [ -f "$file" ] || return 0
    export PYTHONSTARTUP="$file"
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
    if _koopa_is_installed rbenv
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
    prefix="$(_koopa_ruby_packages_prefix)"
    _koopa_activate_prefix "$prefix"
    export GEM_HOME="$prefix"
    return 0
}

_koopa_activate_rust() { # {{{1
    # """
    # Activate Rust programming language.
    # @note Updated 2021-05-07.
    #
    # Attempt to locate cargo home and source the env script.
    # This will put the rust cargo programs defined in 'bin/' in the PATH.
    #
    # Alternatively, can just add '${cargo_home}/bin' to PATH.
    # """
    local cargo_prefix nounset script rustup_prefix
    cargo_prefix="$(_koopa_rust_packages_prefix)"
    rustup_prefix="$(_koopa_rust_prefix)"
    [ -d "$cargo_prefix" ] || return 0
    [ -d "$rustup_prefix" ] || return 0
    script="${cargo_prefix}/env"
    [ -r "$script" ] || return 0
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    export CARGO_HOME="$cargo_prefix"
    export RUSTUP_HOME="$rustup_prefix"
    # shellcheck source=/dev/null
    . "$script"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_secrets() { # {{{1
    # """
    # Source secrets file.
    # @note Updated 2020-07-07.
    # """
    local file
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
    # @note Updated 2020-06-30.
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
    _koopa_is_linux || return 0
    _koopa_is_interactive || return 0
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

_koopa_activate_standard_paths() { # {{{1
    # """
    # Activate standard paths.
    # @note Updated 2021-05-06.
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
    make_prefix="$(_koopa_make_prefix)"
    _koopa_add_to_path_start \
        "${make_prefix}/bin" \
        "${make_prefix}/sbin"
    _koopa_add_to_manpath_start \
        "${make_prefix}/man" \
        "${make_prefix}/share/man"
    return 0
}

_koopa_activate_venv() { # {{{1
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
    [ -n "${VIRTUAL_ENV:-}" ] && return 0
    shell="$(_koopa_shell_name)"
    case "$shell" in
        bash|zsh)
            ;;
        *)
            return 0
            ;;
    esac
    name="${1:-base}"
    prefix="$(_koopa_venv_prefix)"
    script="${prefix}/${name}/bin/activate"
    [ -r "$script" ] || return 0
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    # shellcheck source=/dev/null
    . "$script"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_xdg() { # {{{1
    # """
    # Activate XDG base directory specification.
    # @note Updated 2021-05-21.
    # @seealso
    # - https://developer.gnome.org/basedir-spec/
    # - https://wiki.archlinux.org/index.php/XDG_Base_Directory
    # """
    if [ -z "${XDG_CACHE_HOME:-}" ]
    then
        XDG_CACHE_HOME="$(_koopa_xdg_cache_home)"
    fi
    if [ -z "${XDG_CONFIG_DIRS:-}" ]
    then
        XDG_CONFIG_DIRS="$(_koopa_xdg_config_dirs)"
    fi
    if [ -z "${XDG_CONFIG_HOME:-}" ]
    then
        XDG_CONFIG_HOME="$(_koopa_xdg_config_home)"
    fi
    if [ -z "${XDG_DATA_DIRS:-}" ]
    then
        XDG_DATA_DIRS="$(_koopa_xdg_data_dirs)"
    fi
    if [ -z "${XDG_DATA_HOME:-}" ]
    then
        XDG_DATA_HOME="$(_koopa_xdg_data_home)"
    fi
    if [ -z "${XDG_RUNTIME_DIR:-}" ]
    then
        XDG_RUNTIME_DIR="$(_koopa_xdg_runtime_dir)"
    fi
    export \
        XDG_CACHE_HOME \
        XDG_CONFIG_DIRS \
        XDG_CONFIG_HOME \
        XDG_DATA_DIRS \
        XDG_DATA_HOME \
        XDG_RUNTIME_DIR
    return 0
}

_koopa_macos_activate_python() { # {{{1
    # """
    # Activate macOS Python binary install.
    # @note Updated 2020-11-16.
    # """
    local minor_version version
    [ -z "${VIRTUAL_ENV:-}" ] || return 0
    version="$(_koopa_variable 'python')"
    minor_version="$(_koopa_major_minor_version "$version")"
    _koopa_activate_prefix "/Library/Frameworks/Python.framework/\
Versions/${minor_version}"
    return 0
}

_koopa_macos_activate_visual_studio_code() { # {{{1
    # """
    # Activate Visual Studio Code.
    # @note Updated 2021-03-16.
    # """
    local prefix
    prefix='/Applications/Visual Studio Code.app/Contents/Resources/app/bin'
    _koopa_add_to_path_start "$prefix"
    return 0
}
