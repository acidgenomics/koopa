#!/bin/sh
# shellcheck disable=SC2039

_koopa_activate_prefix() {                                                # {{{1
    # """
    # Automatically configure PATH and MANPATH for a specified prefix.
    # Updated 2020-02-13.
    # """
    local prefix
    prefix="${1:?}"
    _koopa_add_to_path_start "${prefix}/sbin"
    _koopa_add_to_path_start "${prefix}/bin"
    _koopa_add_to_manpath_start "${prefix}/man"
    _koopa_add_to_manpath_start "${prefix}/share/man"
    return 0
}



_koopa_activate_aspera() {                                                # {{{1
    # """
    # Include Aspera Connect binaries in PATH, if defined.
    # Updated 2020-01-12.
    # """
    local prefix
    prefix="$(_koopa_aspera_prefix)"
    [ -d "$prefix" ] || return 0
    _koopa_activate_prefix "$prefix"
    return 0
}

_koopa_activate_autojump() {                                              # {{{1
    # """
    # Activate autojump.
    # Updated 2020-01-24.
    #
    # Purge install with 'j --purge'.
    # Location: ~/.local/share/autojump/autojump.txt
    #
    # See also:
    # - https://github.com/wting/autojump
    # """
    local prefix
    prefix="$(_koopa_autojump_prefix)"
    [ -d "$prefix" ] || return 0
    _koopa_activate_prefix "$prefix"
    local script
    script="${prefix}/etc/profile.d/autojump.sh"
    [ -r "$script" ] || return 0
    local nounset
    nounset="$(_koopa_is_setopt_nounset && echo 1 || echo 0)"
    [ "$nounset" -eq 1 ] && set +u
    # shellcheck source=/dev/null
    . "$script"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_bcbio() {                                                 # {{{1
    # """
    # Include bcbio toolkit binaries in PATH, if defined.
    # Updated 2019-11-15.
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

_koopa_activate_broot() {                                                 # {{{1
    # """
    # Activate broot directory tree utility.
    # Updated 2020-01-24.
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
    nounset="$(_koopa_is_setopt_nounset && echo 1 || echo 0)"
    [ "$nounset" -eq 1 ] && set +u
    # shellcheck source=/dev/null
    . "$br_script"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_conda() {                                                 # {{{1
    # """
    # Activate conda.
    # Updated 2020-01-24.
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
    nounset="$(_koopa_is_setopt_nounset && echo 1 || echo 0)"
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

_koopa_activate_ensembl_perl_api() {                                      # {{{1
    # """
    # Activate Ensembl Perl API.
    # Updated 2019-11-14.
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

_koopa_activate_fzf() {                                                   # {{{1
    # """
    # Activate fzf, command-line fuzzy finder.
    # Updated 2020-01-24.
    #
    # See also:
    # https://github.com/junegunn/fzf
    # """
    _koopa_is_installed fzf || return 0
    local dir
    dir="/usr/local/opt/fzf"
    [ -d "$dir" ] || return 0
    local shell
    shell="$(_koopa_shell)"
    local nounset
    nounset="$(_koopa_is_setopt_nounset && echo 1 || echo 0)"
    [ "$nounset" -eq 1 ] && set +u
    # Auto-completion.
    # shellcheck source=/dev/null
    . "${dir}/shell/completion.${shell}"
    # Key bindings.
    # shellcheck source=/dev/null
    . "${dir}/shell/key-bindings.${shell}"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_llvm() {                                                  # {{{1
    # """
    # Activate LLVM config.
    # Updated 2020-01-22.
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

_koopa_activate_perlbrew() {                                              # {{{1
    # """
    # Activate Perlbrew.
    # Updated 2020-01-24.
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
    nounset="$(_koopa_is_setopt_nounset && echo 1 || echo 0)"
    [ "$nounset" -eq 1 ] && set +u
    # Note that this is also compatible with zsh.
    # shellcheck source=/dev/null
    . "$script"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_pipx() {                                                  # {{{1
    # """
    # Activate pipx for Python.
    # Updated 2020-01-12.
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

_koopa_activate_pyenv() {                                                 # {{{1
    # """
    # Activate Python version manager (pyenv).
    # Updated 2020-01-24.
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
    nounset="$(_koopa_is_setopt_nounset && echo 1 || echo 0)"
    [ "$nounset" -eq 1 ] && set +u
    eval "$("$script" init -)"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_rbenv() {                                                 # {{{1
    # """
    # Activate Ruby version manager (rbenv).
    # Updated 2019-11-15.
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
    nounset="$(_koopa_is_setopt_nounset && echo 1 || echo 0)"
    [ "$nounset" -eq 1 ] && set +u
    eval "$("$script" init -)"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_rust() {                                                  # {{{1
    # """
    # Activate Rust programming language.
    # Updated 2020-01-24.
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
    nounset="$(_koopa_is_setopt_nounset && echo 1 || echo 0)"
    [ "$nounset" -eq 1 ] && set +u
    # shellcheck source=/dev/null
    . "$script"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}

_koopa_activate_secrets() {                                               # {{{1
    # """
    # Source secrets file.
    # Updated 2020-01-12.
    # """
    local file
    file="${1:-"${HOME}/.secrets"}"
    [ -r "$file" ] || return 0
    # shellcheck source=/dev/null
    . "$file"
    return 0
}

_koopa_activate_ssh_key() {                                               # {{{1
    # """
    # Import an SSH key automatically, using 'SSH_KEY' global variable.
    # Updated 2019-10-29.
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

_koopa_activate_venv() {                                                  # {{{1
    # """
    # Activate Python default virtual environment.
    # Updated 2020-01-24.
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
    # Refer to 'declare -f deactivate' for function source code.
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
    nounset="$(_koopa_is_setopt_nounset && echo 1 || echo 0)"
    [ "$nounset" -eq 1 ] && set +u
    # shellcheck source=/dev/null
    . "$script"
    [ "$nounset" -eq 1 ] && set -u
    return 0
}
