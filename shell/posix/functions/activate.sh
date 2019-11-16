#!/bin/sh
# shellcheck disable=SC2039

_koopa_activate_prefix() {                                                # {{{3
    # """
    # Automatically configure PATH and MANPATH for a specified prefix.
    # Updated 2019-11-10.
    # """
    local prefix
    prefix="$1"
    _koopa_has_sudo && _koopa_add_to_path_start "${prefix}/sbin"
    _koopa_add_to_path_start "${prefix}/bin"
    _koopa_add_to_manpath_start "${prefix}/man"
    _koopa_add_to_manpath_start "${prefix}/share/man"
    return 0
}

_koopa_activate_aspera() {                                                # {{{3
    # """
    # Include Aspera Connect binaries in PATH, if defined.
    # Updated 2019-11-15.
    # """
    local prefix
    prefix="$(_koopa_aspera_prefix)"
    [ -d "$prefix" ] || return 0
    _koopa_activate_prefix "$prefix"
}

_koopa_activate_autojump() {                                              # {{{3
    # """
    # Activate autojump.
    # Updated 2019-11-15.
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
    [ -n "${KOOPA_TEST:-}" ] && set +u
    # shellcheck source=/dev/null
    . "$script"
    [ -n "${KOOPA_TEST:-}" ] && set -u
    if [ "$KOOPA_SHELL" = "zsh" ]
    then
        autoload -U compinit && compinit -u
    fi
    return 0
}

_koopa_activate_bcbio() {                                                 # {{{3
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

_koopa_activate_conda() {                                                 # {{{3
    # """
    # Activate conda.
    # Updated 2019-11-14.
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
    name="${2:-"base"}"
    script="${prefix}/bin/activate"
    [ -r "$script" ] || return 0
    [ -n "${KOOPA_TEST:-}" ] && set +u
    # shellcheck source=/dev/null
    . "$script"
    # Ensure base environment gets deactivated by default.
    if [ "$name" = "base" ]
    then
        # Don't use the full conda path here; will return config error.
        conda deactivate
    fi
    [ -n "${KOOPA_TEST:-}" ] && set -u
    return 0
}

_koopa_activate_ensembl_perl_api() {                                      # {{{3
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

_koopa_activate_llvm() {                                                  # {{{3
    # """
    # Activate LLVM config.
    # Updated 2019-11-13.
    #
    # Note that LLVM 7 specifically is now required to install umap-learn.
    # Current version LLVM 9 isn't supported by numba > llvmlite yet.
    #
    # Homebrew LLVM 7
    # > brew install llvm@7
    # """
    local llvm_config
    llvm_config=
    if _koopa_is_rhel7
    then
        llvm_config="/usr/bin/llvm-config-7.0-64"
    elif _koopa_is_darwin
    then
        llvm_config="/usr/local/opt/llvm@7/bin/llvm-config"
    fi
    [ -x "$llvm_config" ] && export LLVM_CONFIG="$llvm_config"
    return 0
}

_koopa_activate_perlbrew() {                                              # {{{3
    # """
    # Activate Perlbrew.
    # Updated 2019-11-15.
    #
    # Only attempt to autoload for bash or zsh.
    #
    # See also:
    # - https://perlbrew.pl
    # """
    [ -z "${PERLBREW_ROOT:-}" ] || return 0
    ! _koopa_is_installed perlbrew || return 0
    _koopa_shell | grep -Eq "^(bash|zsh)$" || return 0
    local prefix
    prefix="$(_koopa_perlbrew_prefix)"
    [ -d "$prefix" ] || return 0
    local script
    script="${prefix}/etc/bashrc"
    [ -r "$script" ] || return 0
    [ -n "${KOOPA_TEST:-}" ] && set +u
    # Note that this is also compatible with zsh.
    # shellcheck source=/dev/null
    . "$script"
    [ -n "${KOOPA_TEST:-}" ] && set -u
    return 0
}

_koopa_activate_pyenv() {                                                 # {{{3
    # """
    # Activate Python version manager (pyenv).
    # Updated 2019-11-15.
    #
    # Note that pyenv forks rbenv, so activation is very similar.
    # """
    if _koopa_is_installed pyenv
    then
        return 0
    fi
    [ -z "${PYENV_ROOT:-}" ] || return 0
    local prefix
    prefix="$(_koopa_pyenv_prefix)"
    [ -d "$prefix" ] || return 0
    local script
    script="${prefix}/bin/pyenv"
    [ -r "$script" ] || return 0
    export PYENV_ROOT="$prefix"
    _koopa_activate_prefix "$prefix"
    eval "$("$script" init -)"
    return 0
}

_koopa_activate_rbenv() {                                                 # {{{3
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
    [ -z "${RBENV_ROOT:-}" ] || return 0
    local prefix
    prefix="$(_koopa_rbenv_prefix)"
    [ -d "$prefix" ] || return 0
    local script
    script="${prefix}/bin/rbenv"
    [ -r "$script" ] || return 0
    export RBENV_ROOT="$prefix"
    _koopa_activate_prefix "$prefix"
    eval "$("$script" init -)"
    return 0
}

_koopa_activate_rust() {                                                  # {{{3
    # """
    # Activate Rust programming language.
    # Updated 2019-10-29.
    #
    # Attempt to locate cargo home and source the env script.
    # This will put the rust cargo programs defined in 'bin/' in the PATH.
    #
    # Alternatively, can just add '${cargo_home}/bin' to PATH.
    # """
    local prefix
    prefix="$(_koopa_rust_prefix)"
    [ -d "$prefix" ] || return 0
    local script
    script="${prefix}/env"
    [ -r "$script" ] || return 0
    # shellcheck source=/dev/null
    . "$script"
    return 0
}

_koopa_activate_secrets() {                                               # {{{3
    # """
    # Source secrets file.
    # Updated 2019-10-29.
    # """
    local file
    file="${1:-}"
    if [ -z "$file" ]
    then
        file="${HOME}/.secrets"
    fi
    [ -r "$file" ] || return 0
    # shellcheck source=/dev/null
    . "$file"
    return 0
}

_koopa_activate_ssh_key() {                                               # {{{3
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

_koopa_activate_venv() {                                                  # {{{3
    # """
    # Activate Python default virtual environment.
    # Updated 2019-11-15.
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
    [ -z "${VIRTUAL_ENV:-}" ] || return 0
    _koopa_shell | grep -Eq "^(bash|zsh)$" || return 0
    local name
    name="${1:-"base"}"
    local prefix
    prefix="$(_koopa_venv_prefix)"
    local script
    script="${prefix}/${name}/bin/activate"
    [ -r "$script" ] || return 0
    # shellcheck source=/dev/null
    . "$script"
    return 0
}
