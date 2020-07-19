#!/bin/sh

_koopa_activate_aliases() { # {{{1
    # """
    # Activate (non-shell-specific) aliases.
    # @note Updated 2020-07-05.
    # """
    # shellcheck disable=SC2039
    local file
    file="${HOME}/.aliases"
    [ -f "$file" ] || return 0
    # shellcheck source=/dev/null
    . "$file"
    return 0
}

_koopa_activate_aspera() { # {{{1
    # """
    # Include Aspera Connect binaries in PATH, if defined.
    # @note Updated 2020-06-30.
    # """
    _koopa_activate_prefix "$(_koopa_aspera_prefix)/latest"
    return 0
}

_koopa_activate_autojump() { # {{{1
    # """
    # Activate autojump.
    # @note Updated 2020-06-30.
    #
    # Currently supports Bash and Zsh.
    # Skip activation on other POSIX shells, such as Dash.
    #
    # Purge install with 'j --purge'.
    # Location: ~/.local/share/autojump/autojump.txt
    #
    # For bash users, autojump keeps track of directories by modifying
    # '$PROMPT_COMMAND'. Do not overwrite '$PROMPT_COMMAND' in this case.
    # > export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND ;} history -a"
    #
    # See also:
    # - https://github.com/wting/autojump
    # """
    # shellcheck disable=SC2039
    local prefix nounset script
    case "$(_koopa_shell)" in
        bash|zsh)
            ;;
        *)
            return 0
            ;;
    esac
    prefix="$(_koopa_autojump_prefix)"
    [ -d "$prefix" ] || return 0
    if [ -z "${PROMPT_COMMAND:-}" ]
    then
        export PROMPT_COMMAND='history -a'
    fi
    _koopa_activate_prefix "$prefix"
    script="${prefix}/etc/profile.d/autojump.sh"
    [ -r "$script" ] || return 0
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    # shellcheck source=/dev/null
    . "$script"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_bcbio() { # {{{1
    # """
    # Include bcbio toolkit binaries in PATH, if defined.
    # @note Updated 2020-06-30.
    #
    # Attempt to locate bcbio installation automatically on supported platforms.
    #
    # Exporting at the end of PATH so we don't mask gcc or R.
    # This is particularly important to avoid unexpected compilation issues
    # due to compilers in conda masking the system versions.
    # """
    # shellcheck disable=SC2039
    local prefix
    _koopa_is_linux || return 0
    _koopa_is_installed bcbio_nextgen.py && return 0
    prefix="$(_koopa_bcbio_prefix)"
    [ -d "$prefix" ] || return 0
    _koopa_force_add_to_path_end "${prefix}/bin"
    unset -v PYTHONHOME PYTHONPATH
    return 0
}

_koopa_activate_broot() { # {{{1
    # """
    # Activate broot directory tree utility.
    # @note Updated 2020-06-30.
    #
    # The br function script must be sourced for activation.
    # See 'broot --install' for details.
    #
    # Configuration file gets saved at '${prefs_dir}/conf.toml'.
    #
    # Note that for macOS, we're assuming installation via Homebrew.
    # If installed as crate, it will use the same path as for Linux.
    #
    # https://github.com/Canop/broot
    # """
    # shellcheck disable=SC2039
    local br_script config_dir nounset
    if _koopa_is_macos
    then
        config_dir="${HOME}/Library/Preferences/org.dystroy.broot"
    else
        config_dir="${HOME}/.config/broot"
    fi
    [ -d "$config_dir" ] || return 0
    br_script="${config_dir}/launcher/bash/br"
    [ -f "$br_script" ] || return 0
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    # shellcheck source=/dev/null
    . "$br_script"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_completion() { # {{{1
    # """
    # Activate completion (with TAB key).
    # @note Updated 2020-06-30.
    # """
    case "$(_koopa_shell)" in
        bash|zsh)
            ;;
        *)
            return 0
            ;;
    esac
    # shellcheck source=/dev/null
    . "$(_koopa_prefix)/etc/completion/"*
    return 0
}

_koopa_activate_conda() { # {{{1
    # """
    # Activate conda.
    # @note Updated 2020-06-30.
    #
    # It's no longer recommended to directly export conda in '$PATH'.
    # Instead source the 'activate' script.
    # This must be reloaded inside of subshells to work correctly.
    # """
    # shellcheck disable=SC2039
    local name nounset prefix
    prefix="${1:-}"
    if [ -z "$prefix" ]
    then
        prefix="$(_koopa_app_prefix)/conda"
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
    if [ "$name" = "base" ]
    then
        # Don't use the full conda path here; will return config error.
        conda deactivate
    fi
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_coreutils() { # {{{1
    # """
    # Activate hardened interactive aliases for coreutils.
    # @note Updated 2020-07-03.
    #
    # These aliases get "unaliased" inside of koopa scripts, and they should
    # only apply to interactive use at the command prompt.
    #
    # macOS ships with a very old version of GNU coreutils. Use Homebrew.
    # """
    _koopa_has_gnu_coreutils || return 0
    alias cp='cp --archive --interactive' # -ai
    alias ln='ln --interactive --no-dereference --symbolic' # -ins
    alias mkdir='mkdir --parents' # -p
    alias mv='mv --interactive' # -i
    alias rm='rm --dir --interactive=once --preserve-root' # -I
    return 0
}

_koopa_activate_dircolors() { # {{{1
    # """
    # Activate directory colors.
    # @note Updated 2020-06-30.
    # """
    # shellcheck disable=SC2039
    local dircolors_file dotfiles_prefix
    _koopa_is_installed dircolors || return 0
    dotfiles_prefix="$(_koopa_dotfiles_prefix)"
    # This will set the 'LD_COLORS' environment variable.
    dircolors_file="${dotfiles_prefix}/app/coreutils/dircolors"
    if [ -f "$dircolors_file" ]
    then
        eval "$(dircolors "$dircolors_file")"
    else
        eval "$(dircolors -b)"
    fi
    unset -v dircolors_file
    alias dir='dir --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias grep='grep --color=auto'
    alias ls='ls --color=auto'
    alias vdir='vdir --color=auto'
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
    # @note Updated 2020-06-30.
    #
    # Note that this currently requires Perl 5.26.
    # > perlbrew switch perl-5.26
    # """
    # shellcheck disable=SC2039
    local prefix
    prefix="$(_koopa_ensembl_perl_api_prefix)"
    [ -d "$prefix" ] || return 0
    _koopa_add_to_path_start "${prefix}/ensembl-git-tools/bin"
    PERL5LIB="${PERL5LIB}:${prefix}/bioperl-1.6.924"
    PERL5LIB="${PERL5LIB}:${prefix}/ensembl/modules"
    PERL5LIB="${PERL5LIB}:${prefix}/ensembl-compara/modules"
    PERL5LIB="${PERL5LIB}:${prefix}/ensembl-variation/modules"
    PERL5LIB="${PERL5LIB}:${prefix}/ensembl-funcgen/modules"
    export PERL5LIB
    return 0
}

_koopa_activate_fzf() { # {{{1
    # """
    # Activate fzf, command-line fuzzy finder.
    # @note Updated 2020-05-05.
    #
    # Currently Bash and Zsh are supported.
    #
    # Shell lockout has been observed on Ubuntu unless we disable 'set -e'.
    #
    # @seealso
    # - https://github.com/junegunn/fzf
    # """
    # shellcheck disable=SC2039
    local nounset prefix script shell
    prefix="$(_koopa_fzf_prefix)/latest"
    [ -d "$prefix" ] || return 0
    _koopa_activate_prefix "$prefix"
    nounset="$(_koopa_boolean_nounset)"
    shell="$(_koopa_shell)"
    # Relax hardened shell temporarily, if necessary.
    if [ "$nounset" -eq 1 ]
    then
        set +e
        set +u
    fi
    # Auto-completion.
    script="${prefix}/shell/completion.${shell}"
    if [ -f "$script" ]
    then
        # shellcheck source=/dev/null
        . "$script"
    fi
    # Key bindings.
    script="${prefix}/shell/key-bindings.${shell}"
    if [ -f "$script" ]
    then
        # shellcheck source=/dev/null
        . "$script"
    fi
    # Reset hardened shell, if necessary.
    if [ "$nounset" -eq 1 ]
    then
        set -e
        set -u
    fi
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

_koopa_activate_go() { # {{{1
    # """
    # Activate Go.
    # @note Updated 2020-07-19.
    # """
    _koopa_is_installed go || return 0
    [ -n "${GOPATH:-}" ] && return 0
    GOPATH="$(_koopa_go_gopath)"
    export GOPATH
    [ ! -d "$GOPATH" ] && mkdir -p "$GOPATH"
    return 0
}

_koopa_activate_homebrew() { # {{{1
    # """
    # Activate Homebrew.
    # @note Updated 2020-06-30.
    # """
    _koopa_is_installed brew || return 0
    HOMEBREW_PREFIX="$(brew --prefix)"
    HOMEBREW_REPOSITORY="$(brew --repo)"
    export HOMEBREW_INSTALL_CLEANUP=1
    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_PREFIX
    export HOMEBREW_REPOSITORY
    # Stopgap fix for TLS SSL issues with some Homebrew casks.
    if [ -x "${HOMEBREW_PREFIX}/opt/curl/bin/curl" ]
    then
        export HOMEBREW_FORCE_BREWED_CURL=1
    fi
    _koopa_activate_homebrew_gnu_prefix coreutils
    _koopa_activate_homebrew_gnu_prefix findutils
    _koopa_activate_homebrew_gnu_prefix gnu-sed
    _koopa_activate_homebrew_gnu_prefix gnu-tar
    _koopa_activate_homebrew_gnu_prefix gnu-units
    _koopa_activate_homebrew_gnu_prefix grep
    _koopa_activate_homebrew_gnu_prefix make
    _koopa_activate_homebrew_google_cloud_sdk
    _koopa_activate_homebrew_libexec_prefix man-db
    _koopa_activate_homebrew_prefix curl
    _koopa_activate_homebrew_prefix ruby
    _koopa_activate_homebrew_prefix sqlite
    _koopa_activate_homebrew_prefix texinfo
    _koopa_activate_homebrew_ruby_gems
    return 0
}

_koopa_activate_homebrew_gnu_prefix() { # {{{1
    # """
    # Activate a cellar-only Homebrew GNU program.
    # @note Updated 2020-06-30.
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
    # shellcheck disable=SC2039
    local prefix
    prefix="$(_koopa_homebrew_prefix)/opt/${1:?}/libexec"
    [ -d "$prefix" ] || return 0
    _koopa_force_add_to_path_start "${prefix}/gnubin"
    _koopa_force_add_to_manpath_start "${prefix}/share/gnuman"
    return 0
}

_koopa_activate_homebrew_google_cloud_sdk() {
    # """
    # Activate Homebrew Google Cloud SDK.
    # @note Updated 2020-06-30.
    # """
    # shellcheck disable=SC2039
    local prefix shell
    prefix="$(_koopa_homebrew_prefix)"
    prefix="${prefix}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
    [ -d "$prefix" ] || return 0
    shell="$(_koopa_shell)"
    if [ -f "${prefix}/path.${shell}.inc" ]
    then
        # shellcheck source=/dev/null
        . "${prefix}/path.${shell}.inc"
    fi
    if [ -f "${prefix}/completion.${shell}.inc" ]
    then
        # shellcheck source=/dev/null
        . "${prefix}/completion.${shell}.inc"

    fi
    return 0
}

_koopa_activate_homebrew_libexec_prefix() { # {{{1
    # """
    # Activate a cellar-only Homebrew program.
    # @note Updated 2020-06-30.
    # """
    _koopa_activate_prefix "$(_koopa_homebrew_prefix)/opt/${1:?}/libexec"
    return 0
}

_koopa_activate_homebrew_prefix() { # {{{1
    # """
    # Activate a cellar-only Homebrew program.
    # @note Updated 2020-06-30.
    # """
    _koopa_activate_prefix "$(_koopa_homebrew_prefix)/opt/${1:?}"
    return 0
}

_koopa_activate_homebrew_ruby_gems() { # {{{1
    # """
    # Activate Homebrew Ruby gems.
    # @note Updated 2020-06-30.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/ruby.rb
    # - https://stackoverflow.com/questions/12287882/
    # """
    _koopa_add_to_path_start "$(_koopa_homebrew_ruby_gems_prefix)"
    return 0
}

_koopa_activate_koopa_paths() { # {{{1
    # """
    # Automatically configure koopa PATH and MANPATH.
    # @note Updated 2020-07-04.
    # """
    # shellcheck disable=SC2039
    local config_prefix host_id koopa_prefix os_id shell
    koopa_prefix="$(_koopa_prefix)"
    _koopa_str_match "${PATH:-}" "$koopa_prefix" && return 0
    config_prefix="$(_koopa_config_prefix)"
    host_id="$(_koopa_host_id)"
    os_id="$(_koopa_os_id)"
    shell="$(_koopa_shell)"
    _koopa_activate_prefix "$koopa_prefix"
    _koopa_activate_prefix "${koopa_prefix}/shell/${shell}"
    if _koopa_is_linux
    then
        _koopa_activate_prefix "${koopa_prefix}/os/linux"
        if _koopa_is_debian
        then
            _koopa_activate_prefix "${koopa_prefix}/os/debian"
        elif _koopa_is_fedora
        then
            _koopa_activate_prefix "${koopa_prefix}/os/fedora"
        fi
        if _koopa_is_rhel
        then
            _koopa_activate_prefix "${koopa_prefix}/os/rhel"
        fi
    fi
    _koopa_activate_prefix \
        "${koopa_prefix}/os/${os_id}" \
        "${koopa_prefix}/host/${host_id}" \
        "${config_prefix}/docker" \
        "${config_prefix}/scripts-private"
    return 0
}

_koopa_activate_llvm() { # {{{1
    # """
    # Activate LLVM config.
    # @note Updated 2020-06-30.
    # """
    # shellcheck disable=SC2039
    local config
    [ -x "${LLVM_CONFIG:-}" ] && return 0
    if _koopa_is_macos
    then
        config='/usr/local/opt/llvm/bin/llvm-config'
    else
        # Note that findutils isn't installed on Linux distros by default
        # (e.g. Docker fedora image), and will error here otherwise.
        _koopa_is_installed find || return 0
        # Attempt to find the latest version automatically.
        config="$(find /usr/bin -name 'llvm-config-*' | sort | tail -n 1)"
    fi
    [ -x "$config" ] && export LLVM_CONFIG="$config"
    return 0
}

_koopa_activate_local_etc_profile() { # {{{1
    # """
    # Source 'profile.d' scripts in '/usr/local/etc'.
    # @note Updated 2020-06-30.
    #
    # Currently only supported for Bash.
    #
    # Can run into issues with autojump due to missing 'BASH' variable on Zsh
    # and Dash shells otherwise.
    # """
    # shellcheck disable=SC2039
    local prefix
    case "$(_koopa_shell)" in
        bash)
            ;;
        *)
            return 0
            ;;
    esac
    prefix="/usr/local/etc/profile.d"
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

_koopa_activate_macos_extras() { # {{{1
    # """
    # Activate macOS-specific extra settings.
    # @note Updated 2020-07-05.
    # """
    # Improve terminal colors.
    if [ -z "${CLICOLOR:-}" ]
    then
        export CLICOLOR=1
    fi
    # Refer to 'man ls' for 'LSCOLORS' section on color designators. #Note that
    # this doesn't get inherited by GNU coreutils, which uses 'LS_COLORS'.
    if [ -z "${LSCOLORS:-}" ]
    then
        export LSCOLORS='Gxfxcxdxbxegedabagacad'
    fi
    return 0
}

_koopa_activate_macos_python() {
    # """
    # Activate macOS Python install.
    # @note Updated 2020-07-03.
    # """
    # shellcheck disable=SC2039
    local minor_version version
    _koopa_is_macos || return 1
    [ -z "${VIRTUAL_ENV:-}" ] || return 0
    version="$(_koopa_variable 'python')"
    minor_version="$(_koopa_major_minor_version "$version")"
    _koopa_add_to_path_start "/Library/Frameworks/Python.framework/\
Versions/${minor_version}/bin"
    return 0
}

_koopa_activate_openjdk() { # {{{1
    # """
    # Activate OpenJDK.
    # @note Updated 2020-06-30.
    #
    # Use Homebrew instead to manage on macOS.
    #
    # We're using a symlink approach here to manage versions.
    # """
    # shellcheck disable=SC2039
    local prefix
    _koopa_is_linux || return 0
    prefix="$(_koopa_openjdk_prefix)/latest"
    [ -d "$prefix" ] || return 0
    _koopa_add_to_path_start "${prefix}/bin"
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
    # shellcheck disable=SC2039
    local nounset prefix script
    [ -n "${PERLBREW_ROOT:-}" ] && return 0
    ! _koopa_is_installed perlbrew || return 0
    _koopa_shell | grep -Eq '^(bash|zsh)$' || return 0
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
    # @note Updated 2020-06-30.
    #
    # Customize pipx location with environment variables.
    # https://pipxproject.github.io/pipx/installation/
    #
    # PIPX_HOME: The default virtual environment location is '~/.local/pipx'
    # and can be overridden by setting the environment variable 'PIPX_HOME'.
    # Virtual environments will be installed to '$PIPX_HOME/venvs').
    #
    # PIPX_BIN_DIR: The default app location is '~/.local/bin' and can be
    # overridden by setting the environment variable 'PIPX_BIN_DIR'.
    # """
    # shellcheck disable=SC2039
    local shared_prefix
    _koopa_is_installed pipx || return 0
    [ -n "${PIPX_HOME:-}" ] && return 0
    [ -n "${PIPX_BIN_DIR:-}" ] && return 0
    shared_prefix="$(_koopa_app_prefix)/python/pipx"
    if [ -d "$shared_prefix" ]
    then
        # Shared user installation.
        PIPX_HOME="$shared_prefix"
        PIPX_BIN_DIR="${shared_prefix}/bin"
    else
        # Local user installation.
        PIPX_HOME="${HOME}/.local/pipx"
        PIPX_BIN_DIR="${HOME}/.local/bin"
    fi
    export PIPX_HOME
    export PIPX_BIN_DIR
    _koopa_add_to_path_start "$PIPX_BIN_DIR"
    return 0
}

_koopa_activate_pkg_config() { # {{{1
    # """
    # Configure PKG_CONFIG_PATH.
    # @note Updated 2020-07-19.
    #
    # These are defined primarily for R environment. In particular these make
    # building tricky pages from source, such as rgdal, sf and others  easier.
    #
    # This is necessary for rgdal, sf packages to install clean.
    # """
    _koopa_add_to_pkg_config_path_start \
        '/usr/share/pkgconfig' \
        '/usr/lib/pkgconfig' \
        '/usr/lib64/pkgconfig' \
        '/usr/lib/x86_64-linux-gnu/pkgconfig' \
        '/usr/local/share/pkgconfig' \
        '/usr/local/lib/pkgconfig' \
        '/usr/local/lib64/pkgconfig' \
        '/usr/local/lib/x86_64-linux-gnu/pkgconfig'
    return 0
}

_koopa_activate_prefix() { # {{{1
    # """
    # Automatically configure PATH and MANPATH for a specified prefix.
    # @note Updated 2020-07-02.
    # """
    # shellcheck disable=SC2039
    local prefix
    for prefix in "$@"
    do
        [ -d "$prefix" ] || continue
        _koopa_add_to_path_start \
            "${prefix}/sbin" \
            "${prefix}/bin"
        _koopa_add_to_manpath_start \
            "${prefix}/man" \
            "${prefix}/share/man"
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
    # shellcheck disable=SC2039
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

_koopa_activate_python_startup() { # {{{1
    # """
    # Activate Python startup configuration.
    # @note Updated 2020-07-13.
    # @seealso
    # - https://stackoverflow.com/questions/33683744/
    # """
    # shellcheck disable=SC2039
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
    #
    # Alternate approaches:
    # > _koopa_add_to_path_start "$(rbenv root)/shims"
    # > _koopa_add_to_path_start "${HOME}/.rbenv/shims"
    # """
    # shellcheck disable=SC2039
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
    # @note Updated 2020-07-17.
    # """
    # shellcheck disable=SC2039
    local gem_home
    gem_home="${GEM_HOME:-}"
    [ -z "$gem_home" ] && gem_home="${HOME}/.gem"
    [ -d "$gem_home" ] || return 0
    _koopa_activate_prefix "$gem_home"
    export GEM_HOME="$gem_home"
    return 0
}

_koopa_activate_rust() { # {{{1
    # """
    # Activate Rust programming language.
    # @note Updated 2020-06-30.
    #
    # Attempt to locate cargo home and source the env script.
    # This will put the rust cargo programs defined in 'bin/' in the PATH.
    #
    # Alternatively, can just add '${cargo_home}/bin' to PATH.
    # """
    # shellcheck disable=SC2039
    local cargo_prefix nounset script shared_cargo_prefix shared_rust_prefix \
        shared_rustup_prefix
    cargo_prefix="$(_koopa_rust_cargo_prefix)"
    [ -d "$cargo_prefix" ] || return 0
    shared_rust_prefix="$(_koopa_app_prefix)/rust"
    shared_cargo_prefix="${shared_rust_prefix}/cargo"
    if [ "$cargo_prefix" = "$shared_cargo_prefix" ]
    then
        shared_rustup_prefix="${shared_rust_prefix}/rustup"
        if [ ! -d "$shared_rustup_prefix" ]
        then
            _koopa_warning "Rustup not installed at '${shared_rustup_prefix}'."
        fi
        export RUSTUP_HOME="$shared_rustup_prefix"
    fi
    script="${cargo_prefix}/env"
    [ -r "$script" ] || return 0
    export CARGO_HOME="$cargo_prefix"
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
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
    # shellcheck disable=SC2039
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
    # shellcheck disable=SC2039
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
    # @note Updated 2020-06-30.
    #
    # Note that here we're making sure local binaries are included.
    # Inspect '/etc/profile' if system PATH appears misconfigured.
    #
    # @seealso
    # - https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard
    # """
    _koopa_force_add_to_path_end \
        '/usr/bin' \
        '/bin' \
        '/usr/sbin' \
        '/sbin'
    _koopa_force_add_to_path_start \
        '/usr/local/sbin' \
        '/usr/local/bin' \
        "${HOME}/.local/bin"
    _koopa_force_add_to_manpath_end '/usr/share/man'
    _koopa_force_add_to_manpath_start \
        '/usr/local/share/man' \
        "${HOME}/.local/share/man"
    return 0
}

_koopa_activate_venv() { # {{{1
    # """
    # Activate Python default virtual environment.
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
    #
    # Note that 'deactivate' is still messing up autojump path.
    # """
    # shellcheck disable=SC2039
    local name nounset prefix script
    [ -n "${VIRTUAL_ENV:-}" ] && return 0
    _koopa_str_match_regex "$(_koopa_shell)" '^(bash|zsh)$' || return 0
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
    # Activate XDG base directory specification
    # @note Updated 2020-06-30.
    #
    # XDG_RUNTIME_DIR:
    # - Can only exist for the duration of the user's login.
    # - Updated every 6 hours or set sticky bit if persistence is desired.
    # - Should not store large files as it may be mounted as a tmpfs.
    #
    # > if [ ! -d "$XDG_RUNTIME_DIR" ]
    # > then
    # >     mkdir -pv "$XDG_RUNTIME_DIR"
    # >     chown "$USER" "$XDG_RUNTIME_DIR"
    # >     chmod 0700 "$XDG_RUNTIME_DIR"
    # > fi
    #
    # @seealso
    # - https://developer.gnome.org/basedir-spec/
    # - https://wiki.archlinux.org/index.php/XDG_Base_Directory
    # """
    if [ -z "${XDG_CACHE_HOME:-}" ]
    then
        XDG_CACHE_HOME="${HOME}/.cache"
    fi
    if [ -z "${XDG_CONFIG_HOME:-}" ]
    then
        XDG_CONFIG_HOME="${HOME}/.config"
    fi
    if [ -z "${XDG_DATA_HOME:-}" ]
    then
        XDG_DATA_HOME="${HOME}/.local/share"
    fi
    if [ -z "${XDG_RUNTIME_DIR:-}" ]
    then
        XDG_RUNTIME_DIR="/run/user/$(_koopa_user_id)"
        if _koopa_is_macos
        then
            XDG_RUNTIME_DIR="/tmp${XDG_RUNTIME_DIR}"
        fi
    fi
    if [ -z "${XDG_DATA_DIRS:-}" ]
    then
        XDG_DATA_DIRS='/usr/local/share:/usr/share'
    fi
    if [ -z "${XDG_CONFIG_DIRS:-}" ]
    then
        XDG_CONFIG_DIRS='/etc/xdg'
    fi
    export XDG_CACHE_HOME XDG_CONFIG_DIRS XDG_CONFIG_HOME XDG_DATA_DIRS \
        XDG_DATA_HOME XDG_RUNTIME_DIR
    return 0
}
