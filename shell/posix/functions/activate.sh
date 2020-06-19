#!/bin/sh
# shellcheck disable=SC2039

_koopa_activate_aliases() {  # {{{1
    # """
    # Activate (non-shell-specific) aliases.
    # @note Updated 2020-06-19.
    # """
    local file
    file="${HOME}/.aliases"
    [ -f "$file" ] || return 0
    # shellcheck source=/dev/null
    . "$file"
    return 0
}

_koopa_activate_aspera() {  # {{{1
    # """
    # Include Aspera Connect binaries in PATH, if defined.
    # @note Updated 2020-05-01.
    # """
    _koopa_activate_prefix "$(_koopa_aspera_prefix)/latest"
}

_koopa_activate_autojump() {  # {{{1
    # """
    # Activate autojump.
    # @note Updated 2020-04-12.
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
    case "$(_koopa_shell)" in
        bash|zsh)
            ;;
        *)
            return 0
            ;;
    esac
    local prefix
    prefix="$(_koopa_autojump_prefix)"
    [ -d "$prefix" ] || return 0
    if [ -z "${PROMPT_COMMAND:-}" ]
    then
        export PROMPT_COMMAND="history -a"
    fi
    _koopa_activate_prefix "$prefix"
    local script
    script="${prefix}/etc/profile.d/autojump.sh"
    [ -r "$script" ] || return 0
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    # shellcheck source=/dev/null
    . "$script"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_bcbio() {  # {{{1
    # """
    # Include bcbio toolkit binaries in PATH, if defined.
    # @note Updated 2019-11-15.
    #
    # Attempt to locate bcbio installation automatically on supported platforms.
    #
    # Exporting at the end of PATH so we don't mask gcc or R.
    # This is particularly important to avoid unexpected compilation issues
    # due to compilers in conda masking the system versions.
    # """
    _koopa_is_linux || return 0
    ! _koopa_is_installed bcbio_nextgen.py || return 0
    local prefix
    prefix="$(_koopa_bcbio_prefix)"
    [ -d "$prefix" ] || return 0
    _koopa_force_add_to_path_end "${prefix}/bin"
    unset -v PYTHONHOME PYTHONPATH
    return 0
}

_koopa_activate_broot() {  # {{{1
    # """
    # Activate broot directory tree utility.
    # @note Updated 2020-01-24.
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
    local config_dir
    if _koopa_is_macos
    then
        config_dir="${HOME}/Library/Preferences/org.dystroy.broot"
    else
        config_dir="${HOME}/.config/broot"
    fi
    [ -d "$config_dir" ] || return 0
    local br_script
    br_script="${config_dir}/launcher/bash/br"
    [ -f "$br_script" ] || return 0
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    # shellcheck source=/dev/null
    . "$br_script"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_conda() {  # {{{1
    # """
    # Activate conda.
    # @note Updated 2020-01-24.
    #
    # It's no longer recommended to directly export conda in '$PATH'.
    # Instead source the 'activate' script.
    # This must be reloaded inside of subshells to work correctly.
    # """
    local prefix
    prefix="${1:-}"
    if [ -z "$prefix" ]
    then
        prefix="$(_koopa_app_prefix)/conda"
    fi
    [ -d "$prefix" ] || return 0
    local name
    name="${2:-base}"
    script="${prefix}/bin/activate"
    [ -r "$script" ] || return 0
    local nounset
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

_koopa_activate_conda_env() {  # {{{1
    # """
    # Activate a conda environment.
    # @note Updated 2020-03-06.
    #
    # Designed to work inside calling scripts and/or subshells.
    #
    # Currently, the conda activation script returns a 'conda()' function in
    # the current shell that doesn't propagate to subshells. This function
    # attempts to rectify the current situation.
    #
    # Note that the conda activation script currently has unbound variables
    # (e.g. PS1), that will cause this step to fail unless we temporarily
    # disable unbound variable checks.
    #
    # Alternate approach:
    # > eval "$(conda shell.bash hook)"
    #
    # See also:
    # - https://github.com/conda/conda/issues/7980
    # - https://stackoverflow.com/questions/34534513
    # """
    _koopa_is_installed conda || return 1
    local name
    name="${1:?}"
    local prefix
    prefix="$(_koopa_conda_prefix)"
    # > _koopa_h1 "Activating '${name}' conda environment."
    # > _koopa_dl "Prefix" "$prefix"
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    if ! type conda | grep -q conda.sh
    then
        # shellcheck source=/dev/null
        . "${prefix}/etc/profile.d/conda.sh"
    fi
    conda activate "$name"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_coreutils() {  # {{{1
    # """
    # Activate hardened interactive aliases for coreutils.
    # @note Updated 2020-06-19.
    #
    # Note that macOS ships with a very old version of GNU coreutils.
    # Update these using Homebrew.
    # """
    local make_prefix
    make_prefix="$(_koopa_make_prefix)"
    if _koopa_str_match \
        "$(_koopa_which_realpath cp)" \
        "$make_prefix"
    then
        alias cp='cp --archive --interactive'
    fi
    if _koopa_str_match \
        "$(_koopa_which_realpath mkdir)" \
        "$make_prefix"
    then
        alias mkdir='mkdir --parents'
    fi
    if _koopa_str_match \
        "$(_koopa_which_realpath mv)" \
        "$make_prefix"
    then
        alias mv="mv --interactive"
    fi
    if _koopa_str_match \
        "$(_koopa_which_realpath rm)" \
        "$make_prefix"
    then
        alias rm='rm --dir --interactive="once" --preserve-root'
    fi
    return 0
}

_koopa_activate_dircolors() {  # {{{1
    # """
    # Activate directory colors.
    # @note Updated 2020-02-14.
    # """
    _koopa_is_installed dircolors || return 0
    local dotfiles_prefix
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

_koopa_activate_emacs() {  # {{{1
    # """
    # Activate Emacs.
    # @note Updated 2020-05-01.
    # """
    _koopa_activate_prefix "${HOME}/.emacs.d"
}

_koopa_activate_ensembl_perl_api() {  # {{{1
    # """
    # Activate Ensembl Perl API.
    # @note Updated 2019-11-14.
    #
    # Note that this currently requires Perl 5.26.
    # > perlbrew switch perl-5.26
    # """
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

_koopa_activate_fzf() {  # {{{1
    # """
    # Activate fzf, command-line fuzzy finder.
    #
    # @note Updated 2020-05-05.
    #
    # Currently Bash and Zsh are supported.
    #
    # Shell lockout has been observed on Ubuntu unless we disable 'set -e'.
    #
    # @seealso
    # - https://github.com/junegunn/fzf
    # """
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

_koopa_activate_gcc_colors() {  # {{{1
    # """
    # Activate GCC colors.
    # @note Updated 2020-02-20.
    # """
    # Colored GCC warnings and errors.
    [ -n "${GCC_COLORS:-}" ] && return 0
    export GCC_COLORS="caret=01;32:error=01;31:locus=01:note=01;36:\
quote=01:warning=01;35"
    return 0
}

_koopa_activate_go() {  # {{{1
    # """
    # Activate Go.
    # @note Updated 2020-03-08.
    # """
    _koopa_is_installed go || return 0
    [ -n "${GOPATH:-}" ] && return 0
    GOPATH="$(_koopa_go_gopath)"
    export GOPATH
    [ ! -d "$GOPATH" ] && _koopa_mkdir "$GOPATH"
    return 0
}

_koopa_activate_homebrew() {  # {{{1
    # """
    # Activate Homebrew.
    # @note Updated 2020-05-01.
    # """
    _koopa_is_installed brew || return 0

    HOMEBREW_PREFIX="$(brew --prefix)"
    export HOMEBREW_PREFIX

    HOMEBREW_REPOSITORY="$(brew --repo)"
    export HOMEBREW_REPOSITORY

    export HOMEBREW_INSTALL_CLEANUP=1
    export HOMEBREW_NO_ANALYTICS=1

    # > _koopa_activate_homebrew_gnu_prefix "binutils"
    _koopa_activate_homebrew_gnu_prefix "coreutils"
    _koopa_activate_homebrew_gnu_prefix "findutils"
    _koopa_activate_homebrew_gnu_prefix "grep"
    _koopa_activate_homebrew_gnu_prefix "make"
    _koopa_activate_homebrew_gnu_prefix "gnu-sed"
    _koopa_activate_homebrew_gnu_prefix "gnu-tar"
    # > _koopa_activate_homebrew_gnu_prefix "gnu-time"
    _koopa_activate_homebrew_gnu_prefix "gnu-units"
    # > _koopa_activate_homebrew_gnu_prefix "gnu-which"
    _koopa_activate_homebrew_prefix "texinfo"
    _koopa_activate_homebrew_prefix "sqlite"
    _koopa_activate_homebrew_libexec_prefix "man-db"
    # > _koopa_activate_homebrew_python
    _koopa_activate_homebrew_google_cloud_sdk

    return 0
}

_koopa_activate_homebrew_gnu_prefix() {  # {{{1
    # """
    # Activate a cellar-only Homebrew GNU program.
    # @note Updated 2020-05-01.
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
    # @note Updated 2020-05-01.
    # """
    local prefix
    prefix="$(_koopa_homebrew_prefix)"
    prefix="${prefix}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
    [ -d "$prefix" ] || return 0
    local shell
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

_koopa_activate_homebrew_libexec_prefix() {  # {{{1
    # """
    # Activate a cellar-only Homebrew program.
    # @note Updated 2020-05-05.
    # """
    _koopa_activate_prefix "$(_koopa_homebrew_prefix)/opt/${1:?}/libexec"

}

_koopa_activate_homebrew_prefix() {  # {{{1
    # """
    # Activate a cellar-only Homebrew program.
    # @note Updated 2020-05-01.
    # """
    _koopa_activate_prefix "$(_koopa_homebrew_prefix)/opt/${1:?}"
}

_koopa_activate_homebrew_python() {
    # """
    # Activate Homebrew Python.
    # @note Updated 2020-05-01.
    #
    # Use official installer in '/Library/Frameworks' instead.
    #
    # Homebrew is lagging on new Python releases, so install manually instead.
    # See 'python.sh' script for activation.
    #
    # Don't add to PATH if a virtual environment is active.
    #
    # @seealso
    # - /usr/local/opt/python/bin
    # - https://docs.brew.sh/Homebrew-and-Python
    # - brew info python
    # """
    [ -z "${VIRTUAL_ENV:-}" ] || return 0
    _koopa_activate_homebrew_prefix "python"
}

_koopa_activate_koopa_paths() {  # {{{1
    # """
    # Automatically configure koopa PATH and MANPATH.
    # @note Updated 2020-06-03.
    # """
    local koopa_prefix
    koopa_prefix="$(_koopa_prefix)"
    _koopa_str_match "${PATH:-}" "$koopa_prefix" && return 0
    local config_prefix
    config_prefix="$(_koopa_config_prefix)"
    local host_id
    host_id="$(_koopa_host_id)"
    local os_id
    os_id="$(_koopa_os_id)"
    local shell
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
    _koopa_activate_prefix "${koopa_prefix}/os/${os_id}"
    _koopa_activate_prefix "${koopa_prefix}/host/${host_id}"
    _koopa_activate_prefix "${config_prefix}/docker"
    _koopa_activate_prefix "${config_prefix}/scripts-private"
    _koopa_add_to_path_end "${koopa_prefix}/system/defunct/bin"
    return 0
}

_koopa_activate_llvm() {  # {{{1
    # """
    # Activate LLVM config.
    # @note Updated 2020-01-22.
    #
    # Note that LLVM 7 specifically is now required to install umap-learn.
    # Current version LLVM 9 isn't supported by numba > llvmlite yet.
    #
    # Homebrew LLVM 7
    # > brew install llvm@7
    # """
    [ -x "${LLVM_CONFIG:-}" ] && return 0
    local config
    if _koopa_is_macos
    then
        # llvm@7
        config="/usr/local/opt/llvm/bin/llvm-config"
    else
        # Note that findutils isn't installed on Linux distros by default
        # (e.g. Docker fedora image), and will error here otherwise.
        ! _koopa_is_installed find && return 0
        # Attempt to find the latest version automatically.
        # RHEL 7: llvm-config-7.0-64
        config="$(find /usr/bin -name "llvm-config-*" | sort | tail -n 1)"
    fi
    [ -x "$config" ] && export LLVM_CONFIG="$config"
    return 0
}

_koopa_activate_local_etc_profile() {  # {{{1
    # """
    # Source 'profile.d' scripts in '/usr/local/etc'.
    # @note Updated 2020-03-27.
    #
    # Currently only supported for Bash.
    #
    # Can run into issues with autojump due to missing 'BASH' variable on Zsh
    # and Dash shells otherwise.
    # """
    case "$(_koopa_shell)" in
        bash)
            ;;
        *)
            return 0
            ;;
    esac
    local prefix
    prefix="$(_koopa_make_prefix)/etc/profile.d"
    [ -d /usr/local/etc/profile.d ] || return 0
    local script
    for script in /usr/local/etc/profile.d/*.sh
    do
        if [ -r "$script" ]
        then
            # shellcheck source=/dev/null
            . "$script"
        fi
    done
    return 0
}

# FIXME REWORK THIS.
_koopa_activate_macos_extras() {  # {{{1
    # """
    # Activate macOS-specific extra settings.
    # @note Updated 2020-06-19.
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
        export LSCOLORS="Gxfxcxdxbxegedabagacad"
    fi

    # Set rsync flags for APFS.
    if [ -z "${RSYNC_FLAGS_APFS:-}" ]
    then
        export RSYNC_FLAGS_APFS="${RSYNC_FLAGS:?} --iconv=utf-8,utf-8-mac"
    fi

    return 0
}

_koopa_activate_macos_python() {
    # """
    # Activate macOS Python install.
    # @note Updated 2020-03-16.
    # """
    _koopa_is_macos || return 1
    [ -z "${VIRTUAL_ENV:-}" ] || return 0
    local version
    version="$(_koopa_variable "python")"
    local minor_version
    minor_version="$(_koopa_major_minor_version "$version")"
    _koopa_add_to_path_start "/Library/Frameworks/Python.framework/\
Versions/${minor_version}/bin"
    return 0
}

_koopa_activate_openjdk() {  # {{{1
    # """
    # Activate OpenJDK.
    # @note Updated 2020-02-27.
    #
    # Use Homebrew instead to manage on macOS.
    #
    # We're using a symlink approach here to manage versions.
    # """
    _koopa_is_linux || return 0
    local prefix
    prefix="$(_koopa_openjdk_prefix)/latest"
    [ -d "$prefix" ] || return 0
    _koopa_add_to_path_start "${prefix}/bin"
    return 0
}

_koopa_activate_perlbrew() {  # {{{1
    # """
    # Activate Perlbrew.
    # @note Updated 2020-01-24.
    #
    # Only attempt to autoload for bash or zsh.
    # Delete '~/.perlbrew' directory if you see errors at login.
    #
    # See also:
    # - https://perlbrew.pl
    # """
    [ -n "${PERLBREW_ROOT:-}" ] && return 0
    ! _koopa_is_installed perlbrew || return 0
    _koopa_shell | grep -Eq "^(bash|zsh)$" || return 0
    local prefix
    prefix="$(_koopa_perlbrew_prefix)"
    [ -d "$prefix" ] || return 0
    local script
    script="${prefix}/etc/bashrc"
    [ -r "$script" ] || return 0
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    # Note that this is also compatible with zsh.
    # shellcheck source=/dev/null
    . "$script"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_pipx() {  # {{{1
    # """
    # Activate pipx for Python.
    # @note Updated 2020-01-12.
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
    _koopa_is_installed pipx || return 0
    [ -n "${PIPX_HOME:-}" ] && return 0
    [ -n "${PIPX_BIN_DIR:-}" ] && return 0
    local shared_prefix
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

_koopa_activate_prefix() {  # {{{1
    # """
    # Automatically configure PATH and MANPATH for a specified prefix.
    # @note Updated 2020-05-01.
    # """
    local prefix
    prefix="${1:?}"
    [ -d "$prefix" ] || return 0
    _koopa_add_to_path_start "${prefix}/sbin"
    _koopa_add_to_path_start "${prefix}/bin"
    _koopa_add_to_manpath_start "${prefix}/man"
    _koopa_add_to_manpath_start "${prefix}/share/man"
    return 0
}

_koopa_activate_pyenv() {  # {{{1
    # """
    # Activate Python version manager (pyenv).
    # @note Updated 2020-01-24.
    #
    # Note that pyenv forks rbenv, so activation is very similar.
    # """
    _koopa_is_installed pyenv && return 0
    [ -n "${PYENV_ROOT:-}" ] && return 0
    local prefix
    prefix="$(_koopa_pyenv_prefix)"
    [ -d "$prefix" ] || return 0
    local script
    script="${prefix}/bin/pyenv"
    [ -r "$script" ] || return 0
    export PYENV_ROOT="$prefix"
    _koopa_activate_prefix "$prefix"
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    eval "$("$script" init -)"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_rbenv() {  # {{{1
    # """
    # Activate Ruby version manager (rbenv).
    # @note Updated 2019-11-15.
    #
    # See also:
    # - https://github.com/rbenv/rbenv
    #
    # Alternate approaches:
    # > _koopa_add_to_path_start "$(rbenv root)/shims"
    # > _koopa_add_to_path_start "${HOME}/.rbenv/shims"
    # """
    if _koopa_is_installed rbenv
    then
        eval "$(rbenv init -)"
        return 0
    fi
    [ -n "${RBENV_ROOT:-}" ] && return 0
    local prefix
    prefix="$(_koopa_rbenv_prefix)"
    [ -d "$prefix" ] || return 0
    local script
    script="${prefix}/bin/rbenv"
    [ -r "$script" ] || return 0
    export RBENV_ROOT="$prefix"
    _koopa_activate_prefix "$prefix"
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    eval "$("$script" init -)"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_ruby() {  # {{{1
    # """
    # Activate Ruby gems.
    # @note Updated 2020-02-13.
    # """
    [ -n "${GEM_HOME:-}" ] && return 0
    local gem_home
    gem_home="${HOME}/.gem"
    if [ -d "$gem_home" ]
    then
        _koopa_add_to_path_start "$gem_home"
        export GEM_HOME="$gem_home"
    fi
    return 0
}

_koopa_activate_rust() {  # {{{1
    # """
    # Activate Rust programming language.
    # @note Updated 2020-01-24.
    #
    # Attempt to locate cargo home and source the env script.
    # This will put the rust cargo programs defined in 'bin/' in the PATH.
    #
    # Alternatively, can just add '${cargo_home}/bin' to PATH.
    # """
    local cargo_prefix
    cargo_prefix="$(_koopa_rust_cargo_prefix)"
    [ -d "$cargo_prefix" ] || return 0
    local shared_rust_prefix
    shared_rust_prefix="$(_koopa_app_prefix)/rust"
    local shared_cargo_prefix
    shared_cargo_prefix="${shared_rust_prefix}/cargo"
    if [ "$cargo_prefix" = "$shared_cargo_prefix" ]
    then
        local shared_rustup_prefix
        shared_rustup_prefix="${shared_rust_prefix}/rustup"
        if [ ! -d "$shared_rustup_prefix" ]
        then
            _koopa_warning "Rustup not installed at '${shared_rustup_prefix}'."
        fi
        export RUSTUP_HOME="$shared_rustup_prefix"
    fi
    local script
    script="${cargo_prefix}/env"
    [ -r "$script" ] || return 0
    export CARGO_HOME="$cargo_prefix"
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    # shellcheck source=/dev/null
    . "$script"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_secrets() {  # {{{1
    # """
    # Source secrets file.
    # @note Updated 2020-02-23.
    # """
    local file
    file="${1:-"${HOME}/.secrets"}"
    [ -r "$file" ] || return 0
    # shellcheck source=/dev/null
    . "$file"
    return 0
}

_koopa_activate_ssh_key() {  # {{{1
    # """
    # Import an SSH key automatically, using 'SSH_KEY' global variable.
    # @note Updated 2019-10-29.
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
    _koopa_is_linux || return 0
    _koopa_is_interactive || return 0
    local key
    key="${SSH_KEY:-"${HOME}/.ssh/id_rsa"}"
    [ -r "$key" ] || return 0
    eval "$(ssh-agent -s)" > /dev/null 2>&1
    ssh-add "$key" > /dev/null 2>&1
    return 0
}

_koopa_activate_standard_paths() {  # {{{1
    # """
    # Activate standard paths.
    # @note Updated 2020-04-12.
    #
    # Note that here we're making sure local binaries are included.
    # Inspect '/etc/profile' if system PATH appears misconfigured.
    #
    # @seealso
    # - https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard
    # """
    _koopa_add_to_path_end '/usr/bin'
    _koopa_add_to_path_end '/bin'
    _koopa_add_to_path_end '/usr/sbin'
    _koopa_add_to_path_end '/sbin'
    _koopa_add_to_manpath_end '/usr/share/man'
    _koopa_force_add_to_path_start '/usr/local/sbin'
    _koopa_force_add_to_path_start '/usr/local/bin'
    _koopa_force_add_to_manpath_start '/usr/local/share/man'
    _koopa_force_add_to_path_start "${HOME}/.local/bin"
    _koopa_force_add_to_manpath_start "${HOME}/.local/share/man"
    return 0
}

_koopa_activate_venv() {  # {{{1
    # """
    # Activate Python default virtual environment.
    # @note Updated 2020-01-24.
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
    [ -n "${VIRTUAL_ENV:-}" ] && return 0
    _koopa_shell | grep -Eq "^(bash|zsh)$" || return 0
    local name
    name="${1:-base}"
    local prefix
    prefix="$(_koopa_venv_prefix)"
    local script
    script="${prefix}/${name}/bin/activate"
    [ -r "$script" ] || return 0
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    # shellcheck source=/dev/null
    . "$script"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_xdg() {  # {{{1
    # """
    # Activate XDG base directory specification
    # @note Updated 2020-04-16.
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
        XDG_RUNTIME_DIR="/run/user/$(_koopa_current_user_id)"
        if _koopa_is_macos
        then
            XDG_RUNTIME_DIR="/tmp${XDG_RUNTIME_DIR}"
        fi
    fi
    if [ -z "${XDG_DATA_DIRS:-}" ]
    then
        XDG_DATA_DIRS="/usr/local/share:/usr/share"
    fi
    if [ -z "${XDG_CONFIG_DIRS:-}" ]
    then
        XDG_CONFIG_DIRS="/etc/xdg"
    fi
    export XDG_CACHE_HOME
    export XDG_CONFIG_DIRS
    export XDG_CONFIG_HOME
    export XDG_DATA_DIRS
    export XDG_DATA_HOME
    export XDG_RUNTIME_DIR
    return 0
}

_koopa_export_cpu_count() {  # {{{1
    # """
    # Export CPU_COUNT.
    # @note Updated 2020-06-03.
    # """
    if [ -z "${CPU_COUNT:-}" ]
    then
        CPU_COUNT="$(_koopa_cpu_count)"
    fi
    export CPU_COUNT
    return 0
}

_koopa_export_dotfiles() {  # {{{1
    # """
    # Activate dotfiles repo.
    # @note Updated 2020-06-19.
    # """
    local dotfiles
    dotfiles="$(_koopa_config_prefix)/dotfiles"
    [ -d "$dotfiles" ] || return 0
    export DOTFILES="$dotfiles"
    return 0
}

_koopa_export_editor() {  # {{{1
    # """
    # Export EDITOR.
    # @note Updated 2020-06-03.
    # """
    # Set text editor, if unset.
    # Recommending vim by default.
    if [ -z "${EDITOR:-}" ]
    then
        export EDITOR="vim"
    fi
    # Ensure VISUAL matches EDITOR.
    if [ -n "${EDITOR:-}" ]
    then
        export VISUAL="$EDITOR"
    fi
    return 0
}

_koopa_export_git() {  # {{{1
    # """
    # Export git configuration.
    # @note Updated 2020-06-03.
    #
    # @seealso
    # https://git-scm.com/docs/merge-options
    # """
    if [ -z "${GIT_MERGE_AUTOEDIT:-}" ]
    then
        export GIT_MERGE_AUTOEDIT="no"
    fi
    return 0
}

_koopa_export_gnupg() {  # {{{1
    # """
    # Export GnuPG settings.
    # @note Updated 2020-06-03.
    #
    # Enable passphrase prompting in terminal.
    # Useful for getting Docker credential store to work.
    # https://github.com/docker/docker-credential-helpers/issues/118
    # """
    if [ -z "${GPG_TTY:-}" ] && _koopa_is_tty
    then
        GPG_TTY="$(tty || true)"
        export GPG_TTY
    fi
    return 0
}

_koopa_export_group() {  # {{{1
    # """
    # Export GROUP.
    # @note Updated 2020-06-03.
    # """
    if [ -z "${GROUP:-}" ]
    then
        GROUP="$(id -gn)"
    fi
    export GROUP
    return 0
}

_koopa_export_history() {  # {{{1
    # """
    # Export history.
    # @note Updated 2020-06-03.
    #
    # See bash(1) for more options.
    # For setting history length, see HISTSIZE and HISTFILESIZE.
    # """
    # Standardize the history file name across shells.
    # Note that snake case is commonly used here across platforms.
    if [ -z "${HISTFILE:-}" ]
    then
        HISTFILE="${HOME}/.$(_koopa_shell)_history"
    fi
    export HISTFILE
    # Create the history file, if necessary.
    # Note that the HOME check here hardens against symlinked data disk failure.
    if [ ! -f "$HISTFILE" ] && [ -e "${HOME:-}" ]
    then
        touch "$HISTFILE"
    fi
    # Don't keep duplicate lines in the history.
    # Alternatively, set "ignoreboth" to also ignore lines starting with space.
    if [ -z "${HISTCONTROL:-}" ]
    then
        HISTCONTROL="ignoredups"
    fi
    export HISTCONTROL
    if [ -z "${HISTIGNORE:-}" ]
    then
        HISTIGNORE="&:ls:[bf]g:exit"
    fi
    export HISTIGNORE
    # Set the default history size.
    if [ -z "${HISTSIZE:-}" ] || [ "${HISTSIZE:-}" -eq 0 ]
    then
        HISTSIZE=1000
    fi
    export HISTSIZE
    # Add the date/time to 'history' command output.
    # Note that on macOS Bash will fail if 'set -e' is set.
    if [ -z "${HISTTIMEFORMAT:-}" ]
    then
        HISTTIMEFORMAT="%Y%m%d %T  "
    fi
    export HISTTIMEFORMAT
    # Ensure that HISTSIZE and SAVEHIST values match.
    if [ "${HISTSIZE:-}" != "${SAVEHIST:-}" ]
    then
        SAVEHIST="$HISTSIZE"
    fi
    export SAVEHIST
    return 0
}

_koopa_export_hostname() {  # {{{1
    # """
    # Export HOSTNAME.
    # @note Updated 2020-06-03.
    # """
    if [ -z "${HOSTNAME:-}" ]
    then
        HOSTNAME="$(uname -n)"
    fi
    export HOSTNAME
    return 0
}

_koopa_export_lesspipe() {  # {{{
    # """
    # Export lesspipe settings.
    # @note Updated 2020-06-03.
    #
    # Preconfigured on some Linux systems at '/etc/profile.d/less.sh'.
    #
    # On some older Linux distros:
    # > eval $(/usr/bin/lesspipe)
    #
    # See also:
    # - https://github.com/wofr06/lesspipe
    # """
    if [ -n "${LESSOPEN:-}" ] &&
        _koopa_is_installed "lesspipe.sh"
    then
        lesspipe_exe="$(_koopa_which_realpath "lesspipe.sh")"
        export LESSOPEN="|${lesspipe_exe} %s"
        export LESS_ADVANCED_PREPROCESSOR=1
    fi
    return 0
}

_koopa_export_ostype() {  # {{{1
    # """
    # Export OSTYPE.
    # @note Updated 2020-06-03.
    #
    # Automatically set by bash and zsh.
    # """
    if [ -z "${OSTYPE:-}" ]
    then
        OSTYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"
    fi
    export OSTYPE
    return 0
}

_koopa_export_pager() {  # {{{1
    # """
    # Export PAGER.
    # @note Updated 2020-06-03.
    # """
    if [ -z "${PAGER:-}" ]
    then
        export PAGER="less"
    fi
    return 0
}

_koopa_export_pkg_config_path() {  # {{{1
    # """
    # These are defined primarily for R environment. In particular these make
    # building tricky pages from source, such as rgdal, sf and others  easier.
    #
    # This is necessary for rgdal, sf packages to install clean.
    # """
    if [ -z "${PKG_CONFIG_PATH:-}" ]
    then
        PKG_CONFIG_PATH="\
    /usr/local/lib64/pkgconfig:\
    /usr/local/lib/pkgconfig:\
    /usr/lib64/pkgconfig:\
    /usr/lib/pkgconfig"
        export PKG_CONFIG_PATH
    fi
    return 0
}

_koopa_export_proj_lib() {  # {{{1
    # """
    # Export PROJ_LIB
    # @note Updated 2020-06-03.
    # """
    if [ -z "${PROJ_LIB:-}" ]
    then
        if [ -e "/usr/local/share/proj" ]
        then
            PROJ_LIB="/usr/local/share/proj"
            export PROJ_LIB
        elif [ -e "/usr/share/proj" ]
        then
            PROJ_LIB="/usr/share/proj"
            export PROJ_LIB
        fi
    fi
    return 0
}

_koopa_export_python() {  # {{{1
    # """
    # Export Python settings.
    # @note Updated 2020-06-03.
    # """
    # Don't allow Python to change the prompt string by default.
    if [ -z "${VIRTUAL_ENV_DISABLE_PROMPT:-}" ]
    then
        export VIRTUAL_ENV_DISABLE_PROMPT=1
    fi
    return 0
}

_koopa_export_rsync() {  # {{{1
    # """
    # Export rsync flags.
    # @note Updated 2020-06-03.
    # """
    if [ -z "${RSYNC_FLAGS:-}" ]
    then
        RSYNC_FLAGS="$(_koopa_rsync_flags)"
        export RSYNC_FLAGS
    fi
    return 0
}

_koopa_export_shell() {  # {{{1
    # """
    # Export SHELL.
    # @note Updated 2020-06-03.
    #
    # Some POSIX shells, such as Dash, don't export this by default.
    # Note that this doesn't currently get set by RStudio terminal.
    # """
    if [ -z "${SHELL:-}" ]
    then
        SHELL="$(_koopa_which "$KOOPA_SHELL")"
    fi
    export SHELL
    return 0
}

_koopa_export_tmpdir() {  # {{{1
    # """
    # Export TMPDIR.
    # @note Updated 2020-06-03.
    # """
    if [ -z "${TMPDIR:-}" ]
    then
        TMPDIR="/tmp"
    fi
    export TMPDIR
    return 0
}

_koopa_export_today() {  # {{{1
    # """
    # Export TODAY.
    # @note Updated 2020-06-03.
    #
    # Current date. Alternatively, can use '%F' shorthand.
    # """
    if [ -z "${TODAY:-}" ]
    then
        TODAY="$(date +%Y-%m-%d)"
    fi
    export TODAY
    return 0
}

_koopa_export_user() {  # {{{1
    # """
    # Export USER.
    # @note Updated 2020-06-03.
    #
    # Alternatively, can use 'whoami' here.
    # """
    if [ -z "${USER:-}" ]
    then
        USER="$(id -un)"
    fi
    export USER
    return 0
}
