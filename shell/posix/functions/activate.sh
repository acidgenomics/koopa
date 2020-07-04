#!/bin/sh
# shellcheck disable=SC2039

koopa::activate_aliases() { # {{{1
    # """
    # Activate (non-shell-specific) aliases.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    local file
    file="${HOME}/.aliases"
    [ -f "$file" ] || return 0
    # shellcheck source=/dev/null
    . "$file"
    return 0
}

koopa::activate_aspera() { # {{{1
    # """
    # Include Aspera Connect binaries in PATH, if defined.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::activate_prefix "$(koopa::aspera_prefix)/latest"
    return 0
}

koopa::activate_autojump() { # {{{1
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
    koopa::assert_has_no_args "$#"
    case "$(koopa::shell)" in
        bash|zsh)
            ;;
        *)
            return 0
            ;;
    esac
    local prefix
    prefix="$(koopa::autojump_prefix)"
    [ -d "$prefix" ] || return 0
    if [ -z "${PROMPT_COMMAND:-}" ]
    then
        export PROMPT_COMMAND="history -a"
    fi
    koopa::activate_prefix "$prefix"
    local script
    script="${prefix}/etc/profile.d/autojump.sh"
    [ -r "$script" ] || return 0
    local nounset
    nounset="$(koopa::boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    # shellcheck source=/dev/null
    . "$script"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

koopa::activate_bcbio() { # {{{1
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
    koopa::assert_has_no_args "$#"
    koopa::is_linux || return 0
    koopa::is_installed bcbio_nextgen.py && return 0
    local prefix
    prefix="$(koopa::bcbio_prefix)"
    [ -d "$prefix" ] || return 0
    koopa::force_add_to_path_end "${prefix}/bin"
    unset -v PYTHONHOME PYTHONPATH
    return 0
}

koopa::activate_broot() { # {{{1
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
    koopa::assert_has_no_args "$#"
    local config_dir
    if koopa::is_macos
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
    nounset="$(koopa::boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    # shellcheck source=/dev/null
    . "$br_script"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

koopa::activate_completion() { # {{{1
    # """
    # Activate completion (with TAB key).
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    case "$(koopa::shell)" in
        bash|zsh)
            ;;
        *)
            return 0
            ;;
    esac
    # shellcheck source=/dev/null
    . "$(koopa::prefix)/etc/completion/"*
    return 0
}

koopa::activate_conda() { # {{{1
    # """
    # Activate conda.
    # @note Updated 2020-06-30.
    #
    # It's no longer recommended to directly export conda in '$PATH'.
    # Instead source the 'activate' script.
    # This must be reloaded inside of subshells to work correctly.
    # """
    koopa::assert_has_no_args "$#"
    local prefix
    prefix="${1:-}"
    if [ -z "$prefix" ]
    then
        prefix="$(koopa::app_prefix)/conda"
    fi
    [ -d "$prefix" ] || return 0
    local name
    name="${2:-base}"
    script="${prefix}/bin/activate"
    [ -r "$script" ] || return 0
    local nounset
    nounset="$(koopa::boolean_nounset)"
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

koopa::activate_conda_env() { # {{{1
    # """
    # Activate a conda environment.
    # @note Updated 2020-06-30.
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
    koopa::assert_has_args "$#"
    koopa::assert_is_installed conda
    local name
    name="${1:?}"
    local prefix
    prefix="$(koopa::conda_prefix)"
    # > koopa::h1 "Activating '${name}' conda environment."
    # > koopa::dl "Prefix" "$prefix"
    local nounset
    nounset="$(koopa::boolean_nounset)"
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

koopa::activate_coreutils() { # {{{1
    # """
    # Activate hardened interactive aliases for coreutils.
    # @note Updated 2020-07-03.
    #
    # These aliases get "unaliased" inside of koopa scripts, and they should
    # only apply to interactive use at the command prompt.
    #
    # macOS ships with a very old version of GNU coreutils. Use Homebrew.
    # """
    koopa::assert_has_no_args "$#"
    koopa::has_gnu_coreutils || return 0
    alias cp="cp --archive --interactive" # -ai
    alias ln="ln --interactive --no-dereference --symbolic" # -ins
    alias mkdir="mkdir --parents" # -p
    alias mv="mv --interactive" # -i
    alias rm="rm --dir --interactive=once --preserve-root" # -I
    return 0
}

koopa::activate_dircolors() { # {{{1
    # """
    # Activate directory colors.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_installed dircolors || return 0
    local dotfiles_prefix
    dotfiles_prefix="$(koopa::dotfiles_prefix)"
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

koopa::activate_emacs() { # {{{1
    # """
    # Activate Emacs.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::activate_prefix "${HOME}/.emacs.d"
    return 0
}

koopa::activate_ensembl_perl_api() { # {{{1
    # """
    # Activate Ensembl Perl API.
    # @note Updated 2020-06-30.
    #
    # Note that this currently requires Perl 5.26.
    # > perlbrew switch perl-5.26
    # """
    koopa::assert_has_no_args "$#"
    local prefix
    prefix="$(koopa::ensembl_perl_api_prefix)"
    [ -d "$prefix" ] || return 0
    koopa::add_to_path_start "${prefix}/ensembl-git-tools/bin"
    PERL5LIB="${PERL5LIB}:${prefix}/bioperl-1.6.924"
    PERL5LIB="${PERL5LIB}:${prefix}/ensembl/modules"
    PERL5LIB="${PERL5LIB}:${prefix}/ensembl-compara/modules"
    PERL5LIB="${PERL5LIB}:${prefix}/ensembl-variation/modules"
    PERL5LIB="${PERL5LIB}:${prefix}/ensembl-funcgen/modules"
    export PERL5LIB
    return 0
}

koopa::activate_fzf() { # {{{1
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
    koopa::assert_has_no_args "$#"
    local nounset prefix script shell
    prefix="$(koopa::fzf_prefix)/latest"
    [ -d "$prefix" ] || return 0
    koopa::activate_prefix "$prefix"
    nounset="$(koopa::boolean_nounset)"
    shell="$(koopa::shell)"
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

koopa::activate_gcc_colors() { # {{{1
    # """
    # Activate GCC colors.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    # Colored GCC warnings and errors.
    [ -n "${GCC_COLORS:-}" ] && return 0
    export GCC_COLORS="caret=01;32:error=01;31:locus=01:note=01;36:\
quote=01:warning=01;35"
    return 0
}

koopa::activate_go() { # {{{1
    # """
    # Activate Go.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_installed go || return 0
    [ -n "${GOPATH:-}" ] && return 0
    GOPATH="$(koopa::go_gopath)"
    export GOPATH
    [ ! -d "$GOPATH" ] && koopa::mkdir "$GOPATH"
    return 0
}

koopa::activate_homebrew() { # {{{1
    # """
    # Activate Homebrew.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_installed brew || return 0
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
    koopa::activate_homebrew_gnu_prefix coreutils
    koopa::activate_homebrew_gnu_prefix findutils
    koopa::activate_homebrew_gnu_prefix gnu-sed
    koopa::activate_homebrew_gnu_prefix gnu-tar
    koopa::activate_homebrew_gnu_prefix gnu-units
    koopa::activate_homebrew_gnu_prefix grep
    koopa::activate_homebrew_gnu_prefix make
    koopa::activate_homebrew_google_cloud_sdk
    koopa::activate_homebrew_libexec_prefix man-db
    koopa::activate_homebrew_prefix curl
    koopa::activate_homebrew_prefix ruby
    koopa::activate_homebrew_prefix sqlite
    koopa::activate_homebrew_prefix texinfo
    koopa::activate_homebrew_ruby_gems
    return 0
}

koopa::activate_homebrew_gnu_prefix() { # {{{1
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
    koopa::assert_has_args "$#"
    local prefix
    prefix="$(koopa::homebrew_prefix)/opt/${1:?}/libexec"
    [ -d "$prefix" ] || return 0
    koopa::force_add_to_path_start "${prefix}/gnubin"
    koopa::force_add_to_manpath_start "${prefix}/share/gnuman"
    return 0
}

koopa::activate_homebrew_google_cloud_sdk() {
    # """
    # Activate Homebrew Google Cloud SDK.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    local prefix shell
    prefix="$(koopa::homebrew_prefix)"
    prefix="${prefix}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
    [ -d "$prefix" ] || return 0
    shell="$(koopa::shell)"
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

koopa::activate_homebrew_libexec_prefix() { # {{{1
    # """
    # Activate a cellar-only Homebrew program.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    koopa::activate_prefix "$(koopa::homebrew_prefix)/opt/${1:?}/libexec"
    return 0
}

koopa::activate_homebrew_prefix() { # {{{1
    # """
    # Activate a cellar-only Homebrew program.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    koopa::activate_prefix "$(koopa::homebrew_prefix)/opt/${1:?}"
    return 0
}

koopa::activate_homebrew_python() {
    # """
    # Activate Homebrew Python.
    # @note Updated 2020-06-30.
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
    koopa::assert_has_no_args "$#"
    [ -z "${VIRTUAL_ENV:-}" ] || return 0
    koopa::activate_homebrew_prefix "python"
    return 0
}

koopa::activate_homebrew_ruby_gems() { # {{{1
    # """
    # Activate Homebrew Ruby gems.
    # @note Updated 2020-06-30.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/ruby.rb
    # - https://stackoverflow.com/questions/12287882/
    # """
    koopa::assert_has_no_args "$#"
    koopa::add_to_path_start "$(koopa::homebrew_ruby_gems_prefix)"
    return 0
}

koopa::activatekoopa::paths() { # {{{1
    # """
    # Automatically configure koopa PATH and MANPATH.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    local config_prefix host_id koopa_prefix os_id shell
    koopa_prefix="$(koopa::prefix)"
    koopa::str_match "${PATH:-}" "$koopa_prefix" && return 0
    config_prefix="$(koopa::config_prefix)"
    host_id="$(koopa::host_id)"
    os_id="$(koopa::os_id)"
    shell="$(koopa::shell)"
    koopa::activate_prefix "$koopa_prefix"
    koopa::activate_prefix "${koopa_prefix}/shell/${shell}"
    if koopa::is_linux
    then
        koopa::activate_prefix "${koopa_prefix}/os/linux"
        if koopa::is_debian
        then
            koopa::activate_prefix "${koopa_prefix}/os/debian"
        elif koopa::is_fedora
        then
            koopa::activate_prefix "${koopa_prefix}/os/fedora"
        fi
        if koopa::is_rhel
        then
            koopa::activate_prefix "${koopa_prefix}/os/rhel"
        fi
    fi
    koopa::activate_prefix \
        "${koopa_prefix}/os/${os_id}" \
        "${koopa_prefix}/host/${host_id}" \
        "${config_prefix}/docker" \
        "${config_prefix}/scripts-private"
    return 0
}

koopa::activate_llvm() { # {{{1
    # """
    # Activate LLVM config.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    [ -x "${LLVM_CONFIG:-}" ] && return 0
    local config
    if koopa::is_macos
    then
        config="/usr/local/opt/llvm/bin/llvm-config"
    else
        # Note that findutils isn't installed on Linux distros by default
        # (e.g. Docker fedora image), and will error here otherwise.
        koopa::is_installed find || return 0
        # Attempt to find the latest version automatically.
        config="$(find /usr/bin -name "llvm-config-*" | sort | tail -n 1)"
    fi
    [ -x "$config" ] && export LLVM_CONFIG="$config"
    return 0
}

koopa::activate_local_etc_profile() { # {{{1
    # """
    # Source 'profile.d' scripts in '/usr/local/etc'.
    # @note Updated 2020-06-30.
    #
    # Currently only supported for Bash.
    #
    # Can run into issues with autojump due to missing 'BASH' variable on Zsh
    # and Dash shells otherwise.
    # """
    koopa::assert_has_no_args "$#"
    case "$(koopa::shell)" in
        bash)
            ;;
        *)
            return 0
            ;;
    esac
    local prefix
    prefix="$(koopa::make_prefix)/etc/profile.d"
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

koopa::activate_macos_extras() { # {{{1
    # """
    # Activate macOS-specific extra settings.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
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

koopa::activate_macos_python() {
    # """
    # Activate macOS Python install.
    # @note Updated 2020-07-03.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_macos
    [ -z "${VIRTUAL_ENV:-}" ] || return 0
    local version
    version="$(koopa::variable "python")"
    local minor_version
    minor_version="$(koopa::major_minor_version "$version")"
    koopa::add_to_path_start "/Library/Frameworks/Python.framework/\
Versions/${minor_version}/bin"
    return 0
}

koopa::activate_openjdk() { # {{{1
    # """
    # Activate OpenJDK.
    # @note Updated 2020-06-30.
    #
    # Use Homebrew instead to manage on macOS.
    #
    # We're using a symlink approach here to manage versions.
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_linux || return 0
    local prefix
    prefix="$(koopa::openjdk_prefix)/latest"
    [ -d "$prefix" ] || return 0
    koopa::add_to_path_start "${prefix}/bin"
    return 0
}

koopa::activate_perlbrew() { # {{{1
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
    koopa::assert_has_no_args "$#"
    [ -n "${PERLBREW_ROOT:-}" ] && return 0
    ! koopa::is_installed perlbrew || return 0
    koopa::shell | grep -Eq "^(bash|zsh)$" || return 0
    local prefix
    prefix="$(koopa::perlbrew_prefix)"
    [ -d "$prefix" ] || return 0
    local script
    script="${prefix}/etc/bashrc"
    [ -r "$script" ] || return 0
    local nounset
    nounset="$(koopa::boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    # Note that this is also compatible with zsh.
    # shellcheck source=/dev/null
    . "$script"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

koopa::activate_pipx() { # {{{1
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
    koopa::assert_has_no_args "$#"
    koopa::is_installed pipx || return 0
    [ -n "${PIPX_HOME:-}" ] && return 0
    [ -n "${PIPX_BIN_DIR:-}" ] && return 0
    local shared_prefix
    shared_prefix="$(koopa::app_prefix)/python/pipx"
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
    koopa::add_to_path_start "$PIPX_BIN_DIR"
    return 0
}

koopa::activate_pkg_config() { # {{{1
    # """
    # Configure PKG_CONFIG_PATH.
    # @note Updated 2020-07-02.
    #
    # These are defined primarily for R environment. In particular these make
    # building tricky pages from source, such as rgdal, sf and others  easier.
    #
    # This is necessary for rgdal, sf packages to install clean.
    # """
    koopa::assert_has_no_args "$#"
    koopa::add_to_pkg_config_start \
        /usr/lib/pkgconfig \
        /usr/lib64/pkgconfig \
        /usr/local/share/pkgconfig \
        /usr/lib/x86_64-linux-gnu/pkgconfig \
        /usr/local/lib/pkgconfig \
        /usr/local/lib64/pkgconfig
    return 0
}

koopa::activate_prefix() { # {{{1
    # """
    # Automatically configure PATH and MANPATH for a specified prefix.
    # @note Updated 2020-07-02.
    # """
    koopa::assert_has_args "$#"
    local prefix
    for prefix in "$@"
    do
        [ -d "$prefix" ] || continue
        koopa::add_to_path_start \
            "${prefix}/sbin" \
            "${prefix}/bin"
        koopa::add_to_manpath_start \
            "${prefix}/man" \
            "${prefix}/share/man"
    done
    return 0
}

koopa::activate_pyenv() { # {{{1
    # """
    # Activate Python version manager (pyenv).
    # @note Updated 2020-06-30.
    #
    # Note that pyenv forks rbenv, so activation is very similar.
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_installed pyenv && return 0
    [ -n "${PYENV_ROOT:-}" ] && return 0
    local prefix
    prefix="$(koopa::pyenv_prefix)"
    [ -d "$prefix" ] || return 0
    local script
    script="${prefix}/bin/pyenv"
    [ -r "$script" ] || return 0
    export PYENV_ROOT="$prefix"
    koopa::activate_prefix "$prefix"
    local nounset
    nounset="$(koopa::boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    eval "$("$script" init -)"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

koopa::activate_rbenv() { # {{{1
    # """
    # Activate Ruby version manager (rbenv).
    # @note Updated 2020-06-30.
    #
    # See also:
    # - https://github.com/rbenv/rbenv
    #
    # Alternate approaches:
    # > koopa::add_to_path_start "$(rbenv root)/shims"
    # > koopa::add_to_path_start "${HOME}/.rbenv/shims"
    # """
    koopa::assert_has_no_args "$#"
    if koopa::is_installed rbenv
    then
        eval "$(rbenv init -)"
        return 0
    fi
    [ -n "${RBENV_ROOT:-}" ] && return 0
    local prefix
    prefix="$(koopa::rbenv_prefix)"
    [ -d "$prefix" ] || return 0
    local script
    script="${prefix}/bin/rbenv"
    [ -r "$script" ] || return 0
    export RBENV_ROOT="$prefix"
    koopa::activate_prefix "$prefix"
    local nounset
    nounset="$(koopa::boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    eval "$("$script" init -)"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

koopa::activate_ruby() { # {{{1
    # """
    # Activate Ruby gems.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    [ -n "${GEM_HOME:-}" ] && return 0
    local gem_home
    gem_home="${HOME}/.gem"
    if [ -d "$gem_home" ]
    then
        koopa::add_to_path_start "$gem_home"
        export GEM_HOME="$gem_home"
    fi
    return 0
}

koopa::activate_rust() { # {{{1
    # """
    # Activate Rust programming language.
    # @note Updated 2020-06-30.
    #
    # Attempt to locate cargo home and source the env script.
    # This will put the rust cargo programs defined in 'bin/' in the PATH.
    #
    # Alternatively, can just add '${cargo_home}/bin' to PATH.
    # """
    koopa::assert_has_no_args "$#"
    local cargo_prefix
    cargo_prefix="$(koopa::rust_cargo_prefix)"
    [ -d "$cargo_prefix" ] || return 0
    local shared_rust_prefix
    shared_rust_prefix="$(koopa::app_prefix)/rust"
    local shared_cargo_prefix
    shared_cargo_prefix="${shared_rust_prefix}/cargo"
    if [ "$cargo_prefix" = "$shared_cargo_prefix" ]
    then
        local shared_rustup_prefix
        shared_rustup_prefix="${shared_rust_prefix}/rustup"
        if [ ! -d "$shared_rustup_prefix" ]
        then
            koopa::warning "Rustup not installed at '${shared_rustup_prefix}'."
        fi
        export RUSTUP_HOME="$shared_rustup_prefix"
    fi
    local script
    script="${cargo_prefix}/env"
    [ -r "$script" ] || return 0
    export CARGO_HOME="$cargo_prefix"
    local nounset
    nounset="$(koopa::boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    # shellcheck source=/dev/null
    . "$script"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

koopa::activate_secrets() { # {{{1
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

koopa::activate_ssh_key() { # {{{1
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
    koopa::is_linux || return 0
    koopa::is_interactive || return 0
    local key
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

koopa::activate_standard_paths() { # {{{1
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
    koopa::assert_has_no_args "$#"
    koopa::force_add_to_path_end \
        "/usr/bin" \
        "/bin" \
        "/usr/sbin" \
        "/sbin"
    koopa::force_add_to_path_start \
        "/usr/local/sbin" \
        "/usr/local/bin" \
        "${HOME}/.local/bin"
    koopa::force_add_to_manpath_end "/usr/share/man"
    koopa::force_add_to_manpath_start \
        "/usr/local/share/man" \
        "${HOME}/.local/share/man"
    return 0
}

koopa::activate_venv() { # {{{1
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
    [ -n "${VIRTUAL_ENV:-}" ] && return 0
    koopa::str_match_regex "$(koopa::shell)" "^(bash|zsh)$" || return 0
    local name nounset prefix script
    name="${1:-base}"
    prefix="$(koopa::venv_prefix)"
    script="${prefix}/${name}/bin/activate"
    [ -r "$script" ] || return 0
    nounset="$(koopa::boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +u
    # shellcheck source=/dev/null
    . "$script"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

koopa::activate_xdg() { # {{{1
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
    koopa::assert_has_no_args "$#"
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
        XDG_RUNTIME_DIR="/run/user/$(koopa::user_id)"
        if koopa::is_macos
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
    koopa::update_xdg_config
    return 0
}

koopa::check_exports() { # {{{1
    # """
    # Check exported environment variables.
    # @note Updated 2020-06-30.
    #
    # Warn the user if they are setting unrecommended values.
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_rstudio && return 0
    koopa::warn_if_export \
        "JAVA_HOME" \
        "LD_LIBRARY_PATH" \
        "PYTHONHOME" \
        "R_HOME"
    return 0
}

koopa::export_cpu_count() { # {{{1
    # """
    # Export CPU_COUNT.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    [ -z "${CPU_COUNT:-}" ] && CPU_COUNT="$(koopa::cpu_count)"
    export CPU_COUNT
    return 0
}

koopa::export_editor() { # {{{1
    # """
    # Export EDITOR.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    [ -z "${EDITOR:-}" ] && EDITOR='vim'
    VISUAL="$EDITOR"
    export EDITOR
    export VISUAL
    return 0
}

koopa::export_git() { # {{{1
    # """
    # Export git configuration.
    # @note Updated 2020-06-30.
    #
    # @seealso
    # https://git-scm.com/docs/merge-options
    # """
    koopa::assert_has_no_args "$#"
    [ -z "${GIT_MERGE_AUTOEDIT:-}" ] && GIT_MERGE_AUTOEDIT='no'
    export GIT_MERGE_AUTOEDIT
    return 0
}

koopa::export_gnupg() { # {{{1
    # """
    # Export GnuPG settings.
    # @note Updated 2020-06-30.
    #
    # Enable passphrase prompting in terminal.
    # Useful for getting Docker credential store to work.
    # https://github.com/docker/docker-credential-helpers/issues/118
    # """
    koopa::assert_has_no_args "$#"
    if [ -z "${GPG_TTY:-}" ] && koopa::is_tty
    then
        GPG_TTY="$(tty || true)"
        export GPG_TTY
    fi
    return 0
}

koopa::export_history() { # {{{1
    # """
    # Export history.
    # @note Updated 2020-06-30.
    #
    # See bash(1) for more options.
    # For setting history length, see HISTSIZE and HISTFILESIZE.
    # """
    koopa::assert_has_no_args "$#"
    # Standardize the history file name across shells.
    # Note that snake case is commonly used here across platforms.
    if [ -z "${HISTFILE:-}" ]
    then
        HISTFILE="${HOME}/.$(koopa::shell)_history"
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

koopa::export_hostname() { # {{{1
    # """
    # Export HOSTNAME.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_no_args "$#"
    [ -z "${HOSTNAME:-}" ] && HOSTNAME="$(koopa::hostname)"
    export HOSTNAME
    return 0
}

koopa::export_lesspipe() { # {{{
    # """
    # Export lesspipe settings.
    # @note Updated 2020-06-30.
    #
    # Preconfigured on some Linux systems at '/etc/profile.d/less.sh'.
    #
    # On some older Linux distros:
    # > eval $(/usr/bin/lesspipe)
    #
    # See also:
    # - https://github.com/wofr06/lesspipe
    # """
    koopa::assert_has_no_args "$#"
    if [ -n "${LESSOPEN:-}" ] &&
        koopa::is_installed "lesspipe.sh"
    then
        lesspipe_exe="$(koopa::which_realpath "lesspipe.sh")"
        export LESSOPEN="|${lesspipe_exe} %s"
        export LESS_ADVANCED_PREPROCESSOR=1
    fi
    return 0
}

koopa::export_ostype() { # {{{1
    # """
    # Export OSTYPE.
    # @note Updated 2020-06-30.
    #
    # Automatically set by bash and zsh.
    # """
    koopa::assert_has_no_args "$#"
    if [ -z "${OSTYPE:-}" ]
    then
        OSTYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"
    fi
    export OSTYPE
    return 0
}

koopa::export_pager() { # {{{1
    # """
    # Export PAGER.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    [ -z "${PAGER:-}" ] && PAGER="less"
    export PAGER
    return 0
}

koopa::export_proj_lib() { # {{{1
    # """
    # Export PROJ_LIB
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
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

koopa::export_python() { # {{{1
    # """
    # Export Python settings.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    # Don't allow Python to change the prompt string by default.
    [ -z "${VIRTUAL_ENV_DISABLE_PROMPT:-}" ] && VIRTUAL_ENV_DISABLE_PROMPT=1
    export VIRTUAL_ENV_DISABLE_PROMPT
    return 0
}

koopa::export_rsync() { # {{{1
    # """
    # Export rsync flags.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    [ -z "${RSYNC_FLAGS:-}" ] && RSYNC_FLAGS="$(koopa::rsync_flags)"
    export RSYNC_FLAGS
    return 0
}

koopa::export_shell() { # {{{1
    # """
    # Export SHELL.
    # @note Updated 2020-06-30.
    #
    # Some POSIX shells, such as Dash, don't export this by default.
    # Note that this doesn't currently get set by RStudio terminal.
    # """
    koopa::assert_has_no_args "$#"
    [ -z "${SHELL:-}" ] && SHELL="$(koopa::which "$(koopa::shell)")"
    export SHELL
    return 0
}

koopa::export_tmpdir() { # {{{1
    # """
    # Export TMPDIR.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    [ -z "${TMPDIR:-}" ] && TMPDIR="/tmp"
    export TMPDIR
    return 0
}

koopa::export_today() { # {{{1
    # """
    # Export TODAY.
    # @note Updated 2020-06-30.
    #
    # Current date. Alternatively, can use '%F' shorthand.
    # """
    koopa::assert_has_no_args "$#"
    [ -z "${TODAY:-}" ] && TODAY="$(date +%Y-%m-%d)"
    export TODAY
    return 0
}

koopa::export_user() { # {{{1
    # """
    # Export USER.
    # @note Updated 2020-06-30.
    #
    # Alternatively, can use 'whoami' here.
    # """
    koopa::assert_has_no_args "$#"
    [ -z "${USER:-}" ] && USER="$(id -un)"
    export USER
    return 0
}

koopa::warn_if_export() { # {{{1
    # """
    # Warn if variable is exported in current shell session.
    # @note Updated 2020-02-20.
    #
    # Useful for checking against unwanted compiler settings.
    # In particular, useful to check for 'LD_LIBRARY_PATH'.
    # """
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if koopa::is_export "$arg"
        then
            koopa::warning "'${arg}' is exported."
        fi
    done
    return 0
}
