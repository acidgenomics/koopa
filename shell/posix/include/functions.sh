#!/bin/sh
# shellcheck disable=SC2039



# A                                                                         {{{1
# ==============================================================================

_acid_activate_aspera() {
    # """
    # Include Aspera Connect binaries in PATH, if defined.
    # Updated 2019-06-25.
    # """
    local prefix
    prefix="${1:-}"
    if [ -z "$prefix" ]
    then
        prefix="${HOME}/.aspera/connect"
    fi
    [ -d "$prefix" ] || return 0
    _acid_add_to_path_start "${prefix}/bin"
    return 0
}

_acid_activate_autojump() {
    # """
    # Activate autojump.
    # Updated 2019-10-29.
    #
    # Currently only supported for ZSH.
    #
    # See also:
    # - https://github.com/wting/autojump
    # """
    local prefix
    prefix="${1:-}"
    if [ -z "$prefix" ]
    then
        prefix="${HOME}/.autojump"
    fi
    local script
    script="${prefix}/etc/profile.d/autojump.sh"
    if [ -r "$script"  ]
    then
        [ -n "${KOOPA_TEST:-}" ] && set +u
        # shellcheck source=/dev/null
        . "$script"
        autoload -U compinit && compinit -u
        [ -n "${KOOPA_TEST:-}" ] && set -u
    fi
}

_acid_activate_bcbio() {
    # """
    # Include bcbio toolkit binaries in PATH, if defined.
    # Updated 2019-10-29.
    #
    # Attempt to locate bcbio installation automatically on supported platforms.
    # """
    _acid_is_linux || return 0
    ! _acid_is_installed bcbio_nextgen.py || return 0
    local prefix
    prefix="${1:-}"
    if [ -z "$prefix" ]
    then
        local host
        host="$(_acid_host_type)"
        if [ "$host" = "harvard-o2" ]
        then
            prefix="/n/app/bcbio/tools"
        elif [ "$host" = "harvard-odyssey" ]
        then
            prefix="/n/regal/hsph_bioinfo/bcbio_nextgen"
        elif [ -d "/usr/local/bcbio/stable/tools" ]
        then
            prefix="/usr/local/bcbio/stable/tools"
        else
            return 0
        fi
    fi
    [ -d "$prefix" ] || return 0
    # Exporting at the end of PATH so we don't mask gcc or R.
    # This is particularly important to avoid unexpected compilation issues
    # due to compilers in conda masking the system versions.
    _acid_force_add_to_path_end "${prefix}/bin"
    unset -v PYTHONHOME PYTHONPATH
    return 0
}

_acid_activate_conda() {
    # """
    # Activate conda.
    # Updated 2019-11-06.
    #
    # It's no longer recommended to directly export conda in '$PATH'.
    # Instead source the 'activate' script.
    #
    # > [ -z "${CONDA_DEFAULT_ENV:-}" ] || return 0
    # > [ -z "${CONDA_PREFIX:-}" ] || return 0
    # > ! _acid_is_installed conda || return 0
    # """
    local prefix
    prefix="${1:-}"
    if [ -z "$prefix" ]
    then
        if [ -d "${HOME}/.local/conda" ]
        then
            prefix="${HOME}/.local/conda"
        elif [ -d "${HOME}/.local/anaconda3" ]
        then
            prefix="${HOME}/.local/anaconda3"
        elif [ -d "${HOME}/.local/miniconda3" ]
        then
            prefix="${HOME}/.local/miniconda3"
        elif [ -d "${HOME}/conda" ]
        then
            prefix="${HOME}/conda"
        elif [ -d "${HOME}/anaconda3" ]
        then
            prefix="${HOME}/anaconda3"
        elif [ -d "${HOME}/miniconda3" ]
        then
            prefix="${HOME}/miniconda3"
        elif [ -d "/usr/local/conda" ]
        then
            prefix="/usr/local/conda"
        elif [ -d "/usr/local/anaconda3" ]
        then
            prefix="/usr/local/anaconda3"
        elif [ -d "/usr/local/miniconda3" ]
        then
            prefix="/usr/local/miniconda3"
        elif [ -d "/opt/conda" ]
        then
            prefix="/opt/conda"
        elif [ -d "/opt/anaconda3" ]
        then
            prefix="/opt/anaconda3"
        elif [ -d "/opt/miniconda3" ]
        then
            prefix="/opt/miniconda3"
        else
            return 0
        fi
    fi
    local name
    name="${2:-"base"}"
    script="${prefix}/bin/activate"
    if [ -r "$script" ]
    then
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
    fi
    return 0
}

_acid_activate_ensembl_perl_api() {
    # """
    # Activate Ensembl Perl API.
    # Updated 2019-10-29.
    #
    # Note that this currently requires Perl 5.26.
    # > perlbrew switch perl-5.26
    # """
    local prefix
    prefix="${1:-}"
    if [ -z "$prefix" ]
    then
        prefix="$(_acid_build_prefix)/ensembl"
    fi
    [ -d "prefix" ] || return 0
    _acid_add_to_path_start "${prefix}/ensembl-git-tools/bin"
    PERL5LIB="${PERL5LIB}:${prefix}/bioperl-1.6.924"
    PERL5LIB="${PERL5LIB}:${prefix}/ensembl/modules"
    PERL5LIB="${PERL5LIB}:${prefix}/ensembl-compara/modules"
    PERL5LIB="${PERL5LIB}:${prefix}/ensembl-variation/modules"
    PERL5LIB="${PERL5LIB}:${prefix}/ensembl-funcgen/modules"
    export PERL5LIB
    return 0
}

_acid_activate_llvm() {
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
    if _acid_is_rhel7
    then
        llvm_config="/usr/bin/llvm-config-7.0-64"
    elif _acid_is_darwin
    then
        llvm_config="/usr/local/opt/llvm@7/bin/llvm-config"
    fi
    [ -x "$llvm_config" ] && export LLVM_CONFIG="$llvm_config"
    return 0
}

_acid_activate_perlbrew() {
    # """
    # Activate Perlbrew.
    # Updated 2019-10-29.
    #
    # Only attempt to autoload for bash or zsh.
    #
    # See also:
    # - https://perlbrew.pl
    # """
    [ -z "${PERLBREW_ROOT:-}" ] || return 0
    ! _acid_is_installed perlbrew || return 0
    _acid_shell | grep -Eq "^(bash|zsh)$" || return 0
    local prefix
    prefix="${1:-}"
    if [ -z "$prefix" ]
    then
        if [ -d "${HOME}/perl5/perlbrew" ]
        then
            prefix="${HOME}/perl5/perlbrew"
        elif [ -d "/usr/local/perlbrew" ]
        then
            prefix="/usr/local/perlbrew"
        else
            return 0
        fi
    fi
    local script
    script="${prefix}/etc/bashrc"
    if [ -r "$script" ]
    then
        [ -n "${KOOPA_TEST:-}" ] && set +u
        # Note that this is also compatible with zsh.
        # shellcheck source=/dev/null
        . "$script"
        [ -n "${KOOPA_TEST:-}" ] && set -u
    fi
    return 0
}

_acid_activate_prefix() {
    # """
    # Automatically configure PATH and MANPATH for a specified prefix.
    # Updated 2019-11-10.
    # """
    local prefix
    prefix="$1"
    _acid_has_sudo && _acid_add_to_path_start "${prefix}/sbin"
    _acid_add_to_path_start "${prefix}/bin"
    _acid_add_to_manpath_start "${prefix}/man"
    _acid_add_to_manpath_start "${prefix}/share/man"
}

_acid_activate_pyenv() {
    # """
    # Activate Python version manager (pyenv).
    # Updated 2019-11-13.
    #
    # Note that pyenv forks rbenv, so activation is very similar.
    # """
    if _acid_is_installed pyenv
    then
        return 0
    fi
    [ -z "${PYENV_ROOT:-}" ] || return 0
    local prefix
    prefix="${1:-}"
    if [ -z "$prefix" ]
    then
        prefix="/usr/local/pyenv"
    fi
    [ -d "$prefix" ] || return 0
    local script
    script="${prefix}/bin/pyenv"
    if [ -r "$script" ]
    then
        export PYENV_ROOT="$prefix"
        _acid_activate_prefix "$prefix"
        eval "$("$script" init -)"
    fi
    return 0
}

_acid_activate_rbenv() {
    # """
    # Activate Ruby version manager (rbenv).
    # Updated 2019-11-13.
    #
    # See also:
    # - https://github.com/rbenv/rbenv
    #
    # Alternate approaches:
    # > _acid_add_to_path_start "$(rbenv root)/shims"
    # > _acid_add_to_path_start "${HOME}/.rbenv/shims"
    # """
    if _acid_is_installed rbenv
    then
        eval "$(rbenv init -)"
        return 0
    fi
    [ -z "${RBENV_ROOT:-}" ] || return 0
    local prefix
    prefix="${1:-}"
    if [ -z "$prefix" ]
    then
        prefix="/usr/local/rbenv"
    fi
    [ -d "$prefix" ] || return 0
    local script
    script="${prefix}/bin/rbenv"
    if [ -r "$script" ]
    then
        export RBENV_ROOT="$prefix"
        _acid_activate_prefix "$prefix"
        eval "$("$script" init -)"
    fi
    return 0
}

_acid_activate_rust() {
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
    prefix="${1:-}"
    if [ -z "$prefix" ]
    then
        prefix="${HOME}/.cargo"
    fi
    [ -d "$prefix" ] || return 0
    local script
    script="${prefix}/env"
    if [ -r "$script" ]
    then
        # shellcheck source=/dev/null
        . "$script"
    fi
    return 0
}

_acid_activate_secrets() {
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
    if [ -r "$file" ]
    then
        # shellcheck source=/dev/null
        . "$file"
    fi
    return 0
}

_acid_activate_ssh_key() {
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
    _acid_is_linux || return 0
    _acid_is_interactive || return 0
    local key
    key="${1:-}"
    if [ -z "$key" ]
    then
        key="${SSH_KEY:-"${HOME}/.ssh/id_rsa"}"
    fi
    [ -r "$key" ] || return 0
    eval "$(ssh-agent -s)" > /dev/null 2>&1
    ssh-add "$key" > /dev/null 2>&1
    return 0
}

_acid_activate_venv() {
    # """
    # Activate Python default virtual environment.
    # Updated 2019-10-29.
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
    _acid_shell | grep -Eq "^(bash|zsh)$" || return 0
    local env_name
    env_name="${1:-}"
    if [ -z "$env_name" ]
    then
        env_name="base"
    fi
    local script
    script="${HOME}/.virtualenvs/${env_name}/bin/activate"
    if [ -r "$script" ]
    then
        # shellcheck source=/dev/null
        . "$script"
    fi
    return 0
}

_acid_add_conda_env_to_path() {
    # Add conda environment to PATH.
    # Consider warning if the environment is missing.
    # Updated 2019-10-21.
    _acid_is_installed conda || return 0
    [ -n "${CONDA_PREFIX:-}" ] || return 0
    local bin_dir
    bin_dir="${CONDA_PREFIX}/envs/${1}/bin"
    [ -d "$bin_dir" ] || return 0
    _acid_add_to_path_start "$bin_dir"
}

_acid_add_config_link() {
    # Add a symlink into the koopa configuration directory.
    #
    # Examples:
    # _acid_add_config_link vimrc
    # _acid_add_config_link vim
    #
    # Updated 2019-09-23.
    local config_dir
    config_dir="$(_acid_config_dir)"
    local source_file
    source_file="$1"
    _acid_assert_is_existing "$source_file"
    source_file="$(realpath "$source_file")"
    local dest_name
    dest_name="$2"
    local dest_file
    dest_file="${config_dir}/${dest_name}"
    rm -fv "$dest_file"
    ln -fnsv "$source_file" "$dest_file"
}

_acid_add_to_fpath_end() {
    # Add directory to end of FPATH.
    # Currently only useful for ZSH activation.
    # Updated 2019-11-11.
    [ ! -d "$1" ] && return 0
    echo "${FPATH:-}" | grep -q "$1" && return 0
    export FPATH="${FPATH:-}:${1}"
}

_acid_add_to_fpath_start() {
    # Add directory to start of FPATH.
    # Currently only useful for ZSH activation.
    # Updated 2019-11-11.
    [ ! -d "$1" ] && return 0
    echo "${FPATH:-}" | grep -q "$1" && return 0
    export FPATH="${1}:${FPATH:-}"
}

_acid_add_to_manpath_end() {
    # Add directory to start of MANPATH.
    # Updated 2019-11-11.
    [ ! -d "$1" ] && return 0
    echo "${MANPATH:-}" | grep -q "$1" && return 0
    export MANPATH="${MANPATH:-}:${1}"
}

_acid_add_to_manpath_start() {
    # Add directory to start of MANPATH.
    # Updated 2019-11-11.
    [ ! -d "$1" ] && return 0
    echo "${MANPATH:-}" | grep -q "$1" && return 0
    export MANPATH="${1}:${MANPATH:-}"
}

_acid_add_to_path_end() {
    # Add directory to end of PATH.
    # Updated 2019-11-11.
    [ ! -d "$1" ] && return 0
    echo "${PATH:-}" | grep -q "$1" && return 0
    export PATH="${PATH:-}:${1}"
}

_acid_add_to_path_start() {
    # Add directory to start of PATH.
    # Updated 2019-11-11.
    [ ! -d "$1" ] && return 0
    echo "$path" | grep -q "$1" && return 0
    export PATH="${1}:${PATH:-}"
}

_acid_array_to_r_vector() {
    # Convert a bash array to an R vector string.
    # Example: ("aaa" "bbb") array to 'c("aaa", "bbb")'.
    # Updated 2019-09-25.
    local x
    x="$(printf '"%s", ' "$@")"
    x="$(_acid_strip_right "$x" ", ")"
    printf "c(%s)\n" "$x"
}

_acid_assert_has_args() {
    # Assert that the user has passed required arguments to a script.
    # Updated 2019-10-23.
    if [ "$#" -eq 0 ]
    then
        _acid_stop "\
Required arguments missing.
Run with '--help' flag for usage details."
    fi
    return 0
}

_acid_assert_has_no_args() {
    # Assert that the user has not passed any arguments to a script.
    # Updated 2019-10-23.
    if [ "$#" -ne 0 ]
    then
        _acid_stop "\
Invalid argument: '${1}'.
Run with '--help' flag for usage details."
    fi
    return 0
}

_acid_assert_has_file_ext() {
    # Assert that input contains a file extension.
    # Updated 2019-10-23.
    if ! _acid_has_file_ext "$1"
    then
        _acid_stop "No file extension: '${1}'."
    fi
    return 0
}

_acid_assert_has_no_envs() {
    # Assert that conda and Python virtual environments aren't active.
    # Updated 2019-10-23.
    if ! _acid_has_no_environments
    then
        _acid_stop "\
Active environment detected.
       (conda and/or python venv)

Deactivate using:
    venv:  deactivate
    conda: conda deactivate

Deactivate venv prior to conda, otherwise conda python may be left in path."
    fi
    return 0
}

_acid_assert_has_sudo() {
    # Assert that current user has sudo (admin) permissions.
    # Updated 2019-10-23.
    if ! _acid_has_sudo
    then
        _acid_stop "sudo is required."
    fi
    return 0
}

_acid_assert_is_conda_active() {
    # Assert that a Conda environment is active.
    # Updated 2019-10-23.
    if ! _acid_is_conda_active
    then
        _acid_stop "No active Conda environment detected."
    fi
    return 0
}

_acid_assert_is_darwin() {
    # Assert that platform is Darwin (macOS).
    # Updated 2019-10-23.
    if ! _acid_is_darwin
    then
        _acid_stop "macOS (Darwin) is required."
    fi
    return 0
}

_acid_assert_is_debian() {
    # Assert that platform is Debian.
    # Updated 2019-10-25.
    if ! _acid_is_debian
    then
        _acid_stop "Debian is required."
    fi
    return 0
}

_acid_assert_is_dir() {
    # Assert that input is a directory.
    # Updated 2019-10-23.
    if [ ! -d "$1" ]
    then
        _acid_stop "Not a directory: '${1}'."
    fi
    return 0
}

_acid_assert_is_executable() {
    # Assert that input is executable.
    # Updated 2019-10-23.
    if [ ! -x "$1" ]
    then
        _acid_stop "Not executable: '${1}'."
    fi
    return 0
}

_acid_assert_is_existing() {
    # Assert that input exists on disk.
    # Note that '-e' flag returns true for file, dir, or symlink.
    # Updated 2019-10-23.
    if [ ! -e "$1" ]
    then
        _acid_stop "Does not exist: '${1}'."
    fi
    return 0
}

_acid_assert_is_fedora() {
    # Assert that platform is Fedora.
    # Updated 2019-10-25.
    if ! _acid_is_fedora
    then
        _acid_stop "Fedora is required."
    fi
    return 0
}

_acid_assert_is_file() {
    # Assert that input is a file.
    # Updated 2019-09-12.
    if [ ! -f "$1" ]
    then
        _acid_stop "Not a file: '${1}'."
    fi
    return 0
}

_acid_assert_is_file_type() {
    # Assert that input matches a specified file type.
    #
    # Example: _acid_assert_is_file_type "$x" "csv"
    #
    # Updated 2019-10-23.
    _acid_assert_is_file "$1"
    _acid_assert_is_matching_regex "$1" "\.${2}\$"
}

_acid_assert_is_git() {
    # Assert that current directory is a git repo.
    # Updated 2019-10-23.
    if ! _acid_is_git
    then
        _acid_stop "Not a git repo."
    fi
    return 0
}

_acid_assert_is_installed() {
    # Assert that programs are installed.
    #
    # Supports checking of multiple programs in a single call.
    # Note that '_acid_is_installed' is not vectorized.
    #
    # Updated 2019-10-23.
    for arg in "$@"
    do
        if ! _acid_is_installed "$arg"
        then
            _acid_stop "'${arg}' is not installed."
        fi
    done
    return 0
}

_acid_assert_is_linux() {
    # Assert that platform is Linux.
    # Updated 2019-10-23.
    if ! _acid_is_linux
    then
        _acid_stop "Linux is required."
    fi
    return 0
}

_acid_assert_is_non_existing() {
    # Assert that input does not exist on disk.
    # Updated 2019-10-23.
    if [ -e "$1" ]
    then
        _acid_stop "Exists: '${1}'."
    fi
    return 0
}

_acid_assert_is_not_dir() {
    # Assert that input is not a directory.
    # Updated 2019-10-23.
    if [ -d "$1" ]
    then
        _acid_stop "Directory exists: '${1}'."
    fi
    return 0
}

_acid_assert_is_not_file() {
    # Assert that input is not a file.
    # Updated 2019-10-23.
    if [ -f "$1" ]
    then
        _acid_stop "File exists: '${1}'."
    fi
    return 0
}

_acid_assert_is_not_installed() {
    # Assert that programs are not installed.
    # Updated 2019-10-23.
    for arg in "$@"
    do
        if _acid_is_installed "$arg"
        then
            _acid_stop "'${arg}' is installed."
        fi
    done
    return 0
}

_acid_assert_is_not_symlink() {
    # Assert that input is not a symbolic link.
    # Updated 2019-10-23.
    if [ -L "$1" ]
    then
        _acid_stop "Symlink exists: '${1}'."
    fi
    return 0
}

_acid_assert_is_r_package_installed() {
    # Assert that a specific R package is installed.
    # Updated 2019-10-23.
    if ! _acid_is_r_package_installed "$1"
    then
        _acid_stop "'${1}' R package is not installed."
    fi
    return 0
}

_acid_assert_is_readable() {
    # Assert that input is readable.
    # Updated 2019-10-23.
    if [ ! -r "$1" ]
    then
        _acid_stop "Not readable: '${1}'."
    fi
    return 0
}

_acid_assert_is_symlink() {
    # Assert that input is a symbolic link.
    # Updated 2019-10-23.
    if [ ! -L "$1" ]
    then
        _acid_stop "Not symlink: '${1}'."
    fi
    return 0
}

_acid_assert_is_venv_active() {
    # Assert that a Python virtual environment is active.
    # Updated 2019-10-23.
    _acid_assert_is_installed pip
    if ! _acid_is_venv_active
    then
        _acid_stop "No active Python venv detected."
    fi
    return 0
}

_acid_assert_is_writable() {
    # Assert that input is writable.
    # Updated 2019-10-23.
    if [ ! -r "$1" ]
    then
        _acid_stop "Not writable: '${1}'."
    fi
    return 0
}

_acid_assert_is_matching_fixed() {
    # Assert that input matches a fixed pattern.
    # Updated 2019-10-23.
    if ! _acid_is_matching_fixed "$1" "$2"
    then
        _acid_stop "'${1}' doesn't match fixed pattern '${2}'."
    fi
    return 0
}

_acid_assert_is_matching_regex() {
    # Assert that input matches a regular expression pattern.
    # Updated 2019-10-23.
    if ! _acid_is_matching_regex "$1" "$2"
    then
        _acid_stop "'${1}' doesn't match regex pattern '${2}'."
    fi
    return 0
}



# B                                                                         {{{1
# ==============================================================================

_acid_basename_sans_ext() {
    # Extract the file basename without extension.
    #
    # Examples:
    # _acid_basename_sans_ext "hello-world.txt"
    # ## hello-world
    #
    # _acid_basename_sans_ext "hello-world.tar.gz"
    # ## hello-world.tar
    #
    # See also: _acid_file_ext
    #
    # Updated 2019-10-08.
    local x
    x="$1"
    if ! _acid_has_file_ext "$x"
    then
        echo "$x"
        return 0
    fi
    x="$(basename "$x")"
    x="${x%.*}"
    echo "$x"
}

_acid_basename_sans_ext2() {
    # Extract the file basename prior to any dots in file name.
    #
    # Examples
    # _acid_basename_sans_ext2 "hello-world.tar.gz"
    # ## hello-world
    #
    # See also: _acid_file_ext2
    #
    # Updated 2019-10-08.
    local x
    x="$1"
    if ! _acid_has_file_ext "$x"
    then
        echo "$x"
        return 0
    fi
    basename "$x" | cut -d '.' -f 1
}

_acid_bash_version() {
    # Updated 2019-09-27.
    bash --version \
        | head -n 1 \
        | cut -d ' ' -f 4 \
        | cut -d '(' -f 1
}

_acid_build_os_string() {
    # Build string for 'make' configuration.
    #
    # Use this for 'configure --build' flag.
    #
    # This function will distinguish between RedHat, Amazon, and other distros
    # instead of just returning "linux". Note that we're substituting "redhat"
    # instead of "rhel" here, when applicable.
    #
    # - AWS:    x86_64-amzn-linux-gnu
    # - Darwin: x86_64-darwin15.6.0
    # - RedHat: x86_64-redhat-linux-gnu
    #
    # Updated 2019-09-27.
    local mach
    local os_type
    local string
    mach="$(uname -m)"
    if _acid_is_darwin
    then
        string="${mach}-${OSTYPE}"
    else
        os_type="$(_acid_os_type)"
        if echo "$os_type" | grep -q "rhel"
        then
            os_type="redhat"
        fi
        string="${mach}-${os_type}-${OSTYPE}"
    fi
    echo "$string"
}

_acid_build_prefix() {
    # Return the installation prefix to use.
    # Updated 2019-09-27.
    local prefix
    if _acid_is_shared && _acid_has_sudo
    then
        prefix="/usr/local"
    else
        prefix="${HOME}/.local"
    fi
    echo "$prefix"
}



# C                                                                         {{{1
# ==============================================================================

_acid_cellar_prefix() {
    # Cellar prefix.
    # Avoid setting to '/usr/local/cellar', as this can conflict with Homebrew.
    # Updated 2019-10-22.
    echo "${KOOPA_HOME}/cellar"
}

_acid_cellar_script() {
    # Return source path for a koopa cellar build script.
    # Updated 2019-11-11.
    local name
    name="$1"
    file="${KOOPA_HOME}/system/include/cellar/${name}.sh"
    _acid_assert_is_file "$file"
    echo "$name"
    echo "$file"
    # > _acid_deactivate_envs
    _acid_assert_has_no_envs
    # shellcheck source=/dev/null
    . "$file"
}

_acid_check_azure() {
    # Check Azure VM integrity.
    # Updated 2019-10-31.
    _acid_is_azure || return 0
    if [ -e "/mnt/resource" ]
    then
        _acid_check_user "/mnt/resource" "root"
        _acid_check_group "/mnt/resource" "root"
        _acid_check_access_octal "/mnt/resource" "1777"
    fi
    _acid_check_mount "/mnt/rdrive"
    return 0
}

_acid_check_access_human() {
    # Check if file or directory has expected human readable access.
    # Updated 2019-10-31.
    if [ ! -e "$1" ]
    then
        _acid_warning "'${1}' does not exist."
        return 1
    fi
    local access
    access="$(_acid_stat_access_human "$1")"
    if [ "$access" != "$2" ]
    then
        _acid_warning "'${1}' current access '${access}' is not '${2}'."
    fi
    return 0
}

_acid_check_access_octal() {
    # Check if file or directory has expected octal access.
    # Updated 2019-10-31.
    if [ ! -e "$1" ]
    then
        _acid_warning "'${1}' does not exist."
        return 1
    fi
    local access
    access="$(_acid_stat_access_octal "$1")"
    if [ "$access" != "$2" ]
    then
        _acid_warning "'${1}' current access '${access}' is not '${2}'."
    fi
    return 0
}

_acid_check_group() {
    # Check if file or directory has an expected group.
    # Updated 2019-10-31.
    if [ ! -e "$1" ]
    then
        _acid_warning "'${1}' does not exist."
        return 1
    fi
    local group
    group="$(_acid_stat_group "$1")"
    if [ "$group" != "$2" ]
    then
        _acid_warning "'${1}' current group '${group}' is not '${2}'."
        return 1
    fi
    return 0
}

_acid_check_mount() {
    # Check if a drive is mounted.
    # Usage of find is recommended over ls here.
    # Updated 2019-10-31.
    if [ "$(find "$1" -mindepth 1 -maxdepth 1 | wc -l)" -eq 0 ]
    then
        _acid_warning "'${1}' is unmounted."
        return 1
    fi
    return 0
}

_acid_check_user() {
    # Check if file or directory has an expected user.
    # Updated 2019-10-31.
    if [ ! -e "$1" ]
    then
        _acid_warning "'${1}' does not exist."
        return 1
    fi
    local user
    user="$(_acid_stat_user "$1")"
    if [ "$user" != "$2" ]
    then
        _acid_warning "'${1}' current user '${user}' is not '${2}'."
        return 1
    fi
    return 0
}

_acid_conda_default_envs_dir() {
    # Locate the directory where conda environments are installed by default.
    # Updated 2019-10-26.
    _acid_assert_is_installed conda
    conda info \
        | grep "envs directories" \
        | cut -d ':' -f 2 \
        | tr -d ' '
}

_acid_conda_env() {
    # Conda environment name.
    #
    # Alternate approach:
    # > CONDA_PROMPT_MODIFIER="($(basename "$CONDA_PREFIX"))"
    # > export CONDA_PROMPT_MODIFIER
    # > conda="$CONDA_PROMPT_MODIFIER"
    #
    # See also:
    # - https://stackoverflow.com/questions/42481726
    #
    # Updated 2019-10-13.
    echo "${CONDA_DEFAULT_ENV:-}"
}

_acid_conda_env_list() {
    # Return a list of conda environments in JSON format.
    # Updated 2019-06-27.
    _acid_is_installed conda || return 1
    conda env list --json
}

_acid_conda_env_prefix() {
    # Return prefix for a specified conda environment.
    #
    # Note that we're allowing env_list passthrough as second positional
    # variable, to speed up loading upon activation.
    #
    # Example: _acid_conda_env_prefix "deeptools"
    #
    # Updated 2019-10-27.
    _acid_is_installed conda || return 1

    local env_name
    env_name="$1"
    [ -n "$env_name" ] || return 1

    local env_list
    env_list="${2:-}"
    if [ -z "$env_list" ]
    then
        env_list="$(_acid_conda_env_list)"
    fi
    env_list="$(echo "$env_list" | grep "$env_name")"
    if [ -z "$env_list" ]
    then
        _acid_stop "Failed to detect prefix for '${env_name}'."
    fi

    local path
    path="$( \
        echo "$env_list" \
        | grep "/envs/${env_name}" \
        | head -n 1 \
    )"
    echo "$path" | sed -E 's/^.*"(.+)".*$/\1/'
}

_acid_conda_internal_prefix() {
    # Path to koopa's internal conda environments.
    # This may be removed in a future update.
    # Updated 2019-10-18.
    echo "${KOOPA_HOME}/conda"
}

_acid_config_dir() {
    # Updated 2019-11-06.
    if [ -z "${XDG_CONFIG_HOME:-}" ]
    then
        # > _acid_warning "'XDG_CONFIG_HOME' is unset."
        XDG_CONFIG_HOME="${HOME}/.config"
    fi
    echo "${XDG_CONFIG_HOME}/koopa"
}

_acid_current_version() {
    # Get the current version of a supported program.
    # Updated 2019-11-12.
    local name
    name="$1"
    local script
    script="${KOOPA_HOME}/system/include/version/${name}.sh"
    if [ ! -x "$script" ]
    then
        _koopa_stop "'${name}' is not supported."
    fi
    "$script"
}



# D                                                                         {{{1
# ==============================================================================

_acid_deactivate_conda() {
    # Deactivate Conda environment.
    # Updated 2019-10-25.
    if [ -n "${CONDA_DEFAULT_ENV:-}" ]
    then
        conda deactivate
    fi
    return 0
}

_acid_deactivate_envs() {
    # Deactivate Conda and Python environments.
    # Updated 2019-10-25.
    _acid_deactivate_venv
    _acid_deactivate_conda
}

_acid_deactivate_venv() {
    # Deactivate Python virtual environment.
    # Updated 2019-10-25.
    if [ -n "${VIRTUAL_ENV:-}" ]
    then
        # This approach messes up autojump path.
        # # shellcheck disable=SC1090
        # > source "${VIRTUAL_ENV}/bin/activate"
        # > deactivate
        _acid_remove_from_path "${VIRTUAL_ENV}/bin"
        unset -v VIRTUAL_ENV
    fi
    return 0
}

_acid_delete_dotfile() {
    # Delete a dot file.
    # Updated 2019-06-27.
    local path
    local name
    path="${HOME}/.${1}"
    name="$(basename "$path")"
    if [ -L "$path" ]
    then
        _acid_message "Removing '${name}'."
        rm -f "$path"
    elif [ -f "$path" ] || [ -d "$path" ]
    then
        _acid_warning "Not a symlink: '${name}'."
    fi
}

_acid_disk_check() {
    # Check that disk has enough free space.
    # Updated 2019-10-27.
    local used
    local limit
    used="$(_acid_disk_pct_used "$@")"
    limit="90"
    if [ "$used" -gt "$limit" ]
    then
        _acid_warning "Disk usage is ${used}%."
    fi
    return 0
}

_acid_disk_pct_used() {
    # Check disk usage on main drive.
    # Updated 2019-08-17.
    local disk
    disk="${1:-/}"
    df "$disk" \
        | head -n 2 \
        | sed -n '2p' \
        | grep -Eo "([.0-9]+%)" \
        | head -n 1 \
        | sed 's/%$//'
}

_acid_dotfiles_config_link() {
    # Dotfiles directory.
    # Note that we're not checking for existence here, which is handled inside
    # 'link-dotfile' script automatically instead.
    # Updated 2019-11-04.
    echo "$(_acid_config_dir)/dotfiles"
}

_acid_dotfiles_private_config_link() {
    # Updated 2019-11-04.
    echo "$(_acid_dotfiles_config_link)-private"
}

_acid_dotfiles_source_repo() {
    # Dotfiles source repository.
    # Updated 2019-11-04.
    if [ -d "${DOTFILES:-}" ]
    then
        echo "$DOTFILES"
        return 0
    fi
    local dotfiles
    dotfiles="$(_acid_home)/dotfiles"
    if [ ! -d "$dotfiles" ]
    then
        _acid_stop "Dotfiles are not installed at '${dotfiles}'."
    fi
    echo "$dotfiles"
}

_acid_download() {
    # Download a file.
    # Alternatively, can use wget instead of curl:
    # > wget -O file url
    # > wget -q -O - url (piped to stdout)
    # > wget -qO-
    # Updated 2019-11-04.
    _acid_assert_is_installed curl
    local url
    url="$1"
    local file
    file="${2:-}"
    if [ -z "$file" ]
    then
        file="$(basename "$url")"
    fi
    curl -L -o "$file" "$url"
}



# E                                                                         {{{1
# ==============================================================================

_acid_echo_ansi() {
    # Print a colored line in console.
    #
    # Currently using ANSI escape codes.
    # This is the classic 8 color terminal approach.
    #
    # - '0;': normal
    # - '1;': bright or bold
    #
    # (taken from Travis CI config)
    # - clear=\033[0K
    # - nocolor=\033[0m
    #
    # echo command requires '-e' flag to allow backslash escapes.
    #
    # See also:
    # - https://en.wikipedia.org/wiki/ANSI_escape_code
    # - https://stackoverflow.com/questions/5947742
    # - https://stackoverflow.com/questions/15736223
    # - https://bixense.com/clicolors/
    #
    # Updated 2019-10-23.
    local color escape nocolor string
    escape="$1"
    string="$2"
    nocolor="\033[0m"
    color="\033[${escape}m"
    # > printf "%b%s%b\n" "$color" "$nocolor" "$string"
    echo -e "${color}${string}${nocolor}"
}

_acid_echo_black() {
    _acid_echo_ansi "0;30" "$1"
}

_acid_echo_black_bold() {
    _acid_echo_ansi "1;30" "$1"
}

_acid_echo_blue() {
    _acid_echo_ansi "0;34" "$1"
}

_acid_echo_blue_bold() {
    _acid_echo_ansi "1;34" "$1"
}

_acid_echo_cyan() {
    _acid_echo_ansi "0;36" "$1"
}

_acid_echo_cyan_bold() {
    _acid_echo_ansi "1;36" "$1"
}

_acid_echo_green() {
    _acid_echo_ansi "0;32" "$1"
}

_acid_echo_green_bold() {
    _acid_echo_ansi "1;32" "$1"
}

_acid_echo_magenta() {
    _acid_echo_ansi "0;35" "$1"
}

_acid_echo_magenta_bold() {
    _acid_echo_ansi "1;35" "$1"
}

_acid_echo_red() {
    _acid_echo_ansi "0;31" "$1"
}

_acid_echo_red_bold() {
    _acid_echo_ansi "1;31" "$1"
}

_acid_echo_yellow() {
    _acid_echo_ansi "0;33" "$1"
}

_acid_echo_yellow_bold() {
    _acid_echo_ansi "1;33" "$1"
}

_acid_echo_white() {
    _acid_echo_ansi "0;37" "$1"
}

_acid_echo_white_bold() {
    _acid_echo_ansi "1;37" "$1"
}

_acid_ensure_newline_at_end_of_file() {
    # Ensure output CSV contains trailing line break.
    #
    # Otherwise 'readr::read_csv()' will skip the last line in R.
    # https://unix.stackexchange.com/questions/31947
    #
    # Benchmarks:
    # vi -ecwq file                                    2.544 sec
    # paste file 1<> file                             31.943 sec
    # ed -s file <<< w                             1m  4.422 sec
    # sed -i -e '$a\' file                         3m 20.931 sec
    #
    # Updated 2019-10-11.
    [ -n "$(tail -c1 "$1")" ] && printf '\n' >>"$1"
}

_acid_extract() {
    # Extract compressed files automatically.
    #
    # As suggested by Mendel Cooper in "Advanced Bash Scripting Guide".
    #
    # See also:
    # - https://github.com/stephenturner/oneliners
    #6
    # Updated 2019-10-27.
    local file
    file="$1"
    if [ ! -f "$file" ]
    then
        _acid_stop "Invalid file: '${file}'."
    fi
    _acid_message "Extracting '${file}'."
    case "$file" in
        *.tar.bz2)
            tar -xjvf "$file"
            ;;
        *.tar.gz)
            tar -xzvf "$file"
            ;;
        *.tar.xz)
            tar -xJvf "$file"
            ;;
        *.bz2)
            bunzip2 "$file"
            ;;
        *.gz)
            gunzip "$file"
            ;;
        *.rar)
            unrar -x "$file"
            ;;
        *.tar)
            tar -xvf "$file"
            ;;
        *.tbz2)
            tar -xjvf "$file"
            ;;
        *.tgz)
            tar -xzvf "$file"
            ;;
        *.zip)
            unzip "$file"
            ;;
        *.Z)
            uncompress "$file"
            ;;
        *.7z)
            7z -x "$file"
            ;;
        *)
            _acid_stop "Unsupported extension: '${file}'."
            ;;
   esac
}



# F                                                                         {{{1
# ==============================================================================

_acid_file_ext() {
    # Extract the file extension from input.
    #
    # Examples:
    # _acid_file_ext "hello-world.txt"
    # ## txt
    #
    # _acid_file_ext "hello-world.tar.gz"
    # ## gz
    #
    # See also: _acid_basename_sans_ext
    #
    # Updated 2019-10-08.
    _acid_has_file_ext "$1" || return 0
    printf "%s\n" "${1##*.}"
}

_acid_file_ext2() {
    # Extract the file extension after any dots in the file name.
    # This assumes file names are not in dotted case.
    #
    # Examples:
    # _acid_file_ext2 "hello-world.tar.gz"
    # ## tar.gz
    #
    # See also: _acid_basename_sans_ext2
    #
    # Updated 2019-10-08.
    _acid_has_file_ext "$1" || return 0
    echo "$1" | cut -d '.' -f 2-
}

_acid_find_dotfiles() {
    # Find dotfiles by type.
    # 1. Type ('f' file; or 'd' directory).
    # 2. Header message (e.g. "Files")
    # Updated 2019-10-22.
    local type="$1"
    local header="$2"
    printf "\n%s:\n\n" "$header"
    find "$HOME" \
        -maxdepth 1 \
        -name ".*" \
        -type "$type" \
        -print0 \
        | xargs -0 -n1 basename \
        | sort \
        | awk '{print "  ",$0}'
}

_acid_find_text() {
    # Find text in any file.
    #
    # See also: https://github.com/stephenturner/oneliners
    #
    # Examples:
    # _acid_find_text "mytext" *.txt
    #
    # Updated 2019-09-05.
    find . -name "$2" -exec grep -il "$1" {} \;;
}

_acid_force_add_to_fpath_end() {
    # Updated 2019-10-27.
    _acid_remove_from_fpath "$1"
    _acid_add_to_fpath_end "$1"
}

_acid_force_add_to_fpath_start() {
    # Updated 2019-10-27.
    _acid_remove_from_fpath "$1"
    _acid_add_to_fpath_start "$1"
}

_acid_force_add_to_manpath_end() {
    # Updated 2019-10-27.
    _acid_remove_from_manpath "$1"
    _acid_add_to_manpath_end "$1"
}

_acid_force_add_to_manpath_start() {
    # Updated 2019-10-14.
    _acid_remove_from_manpath "$1"
    _acid_add_to_manpath_start "$1"
}

_acid_force_add_to_path_end() {
    # Updated 2019-10-14.
    _acid_remove_from_path "$1"
    _acid_add_to_path_end "$1"
}

_acid_force_add_to_path_start() {
    # Updated 2019-10-14.
    _acid_remove_from_path "$1"
    _acid_add_to_path_start "$1"
}




# G                                                                         {{{1
# ==============================================================================

_acid_git_branch() {
    # Current git branch name.
    # Handles detached HEAD state.
    #
    # Alternatives:
    # > git name-rev --name-only HEAD
    # > git rev-parse --abbrev-ref HEAD
    #
    # See also:
    # - _acid_assert_is_git
    # - https://git.kernel.org/pub/scm/git/git.git/tree/contrib/completion/
    #       git-completion.bash?id=HEAD
    #
    # Updated 2019-10-13.
    git symbolic-ref --short -q HEAD
}

_acid_github_latest_release() {
    # Get the latest release version from GitHub.
    # Updated 2019-10-24.
    # Example: _acid_github_latest_release "acidgenomics/koopa"
    curl -s "https://github.com/${1}/releases/latest" 2>&1 \
        | grep -Eo '/tag/[.0-9v]+' \
        | cut -d '/' -f 3 \
        | sed 's/^v//'
}

_acid_group() {
    # Return the approach group to use with koopa installation.
    #
    # Returns current user for local install.
    # Dynamically returns the admin group for shared install.
    #
    # Admin group priority: admin (macOS), sudo (Debian), wheel (Fedora).
    #
    # Updated 2019-10-22.
    local group
    if _acid_is_shared && _acid_has_sudo
    then
        if groups | grep -Eq "\b(admin)\b"
        then
            group="admin"
        elif groups | grep -Eq "\b(sudo)\b"
        then
            group="sudo"
        elif groups | grep -Eq "\b(wheel)\b"
        then
            group="wheel"
        else
            group="$(whoami)"
        fi
    else
        group="$(whoami)"
    fi
    echo "$group"
}

_acid_gsub() {
    # Updated 2019-10-09.
    echo "$1" | sed -E "s/${2}/${3}/g"
}



# H                                                                         {{{1
# ==============================================================================

_acid_has_file_ext() {
    # Does the input contain a file extension?
    # Simply looks for a "." and returns true/false.
    # Updated 2019-10-08.
    echo "$1" | grep -q "\."
}

_acid_has_no_environments() {
    # Detect activation of virtual environments.
    # Updated 2019-10-20.
    _acid_is_conda_active && return 1
    _acid_is_venv_active && return 1
    return 0
}

_acid_has_sudo() {
    # Check that current user has administrator (sudo) permission.
    #
    # Note that use of 'sudo -v' does not work consistently across platforms.
    #
    # - Darwin (macOS): admin
    # - Debian: sudo
    # - Fedora: wheel
    #
    # Updated 2019-09-28.
    groups | grep -Eq "\b(admin|sudo|wheel)\b"
}

_acid_header() {
    # Source script header.
    # Useful for private scripts using koopa code outside of package.
    # Updated 2019-11-10.
    local path
    if [ -z "${1:-}" ]
    then
        >&2 cat << EOF
error: TYPE argument missing.
usage: _acid_header TYPE

shell:
    - bash
    - zsh

os type:
    - darwin
    - linux
        - debian
            - ubuntu
        - fedora
            - [rhel]
                - amzn

host type:
    - aws
    - azure
EOF
        return 1
    fi
    case "$1" in
        # shell ----------------------------------------------------------------
        bash)
            path="${KOOPA_HOME}/shell/bash/include/header.sh"
            ;;
        zsh)
            path="${KOOPA_HOME}/shell/zsh/include/header.sh"
            ;;
        # os -------------------------------------------------------------------
        darwin)
            path="${KOOPA_HOME}/os/darwin/include/header.sh"
            ;;
        linux)
            path="${KOOPA_HOME}/os/linux/include/header.sh"
            ;;
            debian)
                path="${KOOPA_HOME}/os/debian/include/header.sh"
                ;;
                ubuntu)
                    path="${KOOPA_HOME}/os/ubuntu/include/header.sh"
                    ;;
            fedora)
                path="${KOOPA_HOME}/os/fedora/include/header.sh"
                ;;
                amzn)
                    path="${KOOPA_HOME}/os/amzn/include/header.sh"
                    ;;
        # host -----------------------------------------------------------------
        aws)
            path="${KOOPA_HOME}/host/aws/include/header.sh"
            ;;
        azure)
            path="${KOOPA_HOME}/host/azure/include/header.sh"
            ;;
        *)
            _acid_stop "'${1}' is not supported."
            ;;
    esac
    echo "$path"
}

_acid_home() {
    # Updated 2019-08-18.
    echo "$KOOPA_HOME"
}

_acid_host_type() {
    # Simple host type name string to load up host-specific scripts.
    # Currently intended to support AWS, Azure, and Harvard clusters.
    #
    # Returns useful host type matching either:
    # - VMs: "aws", "azure".
    # - HPCs: "harvard-o2", "harvard-odyssey".
    #
    # Returns empty for local machines and/or unsupported types.
    # Updated 2019-08-18.
    local name
    case "$(hostname -f)" in
        # VMs
        *.ec2.internal)
            name="aws"
            ;;
        azlabapp*)
            name="azure"
            ;;
        # HPCs
        *.o2.rc.hms.harvard.edu)
            name="harvard-o2"
            ;;
        *.rc.fas.harvard.edu)
            name="harvard-odyssey"
            ;;
        *)
            name=
            ;;
    esac
    echo "$name"
}



# I                                                                         {{{1
# ==============================================================================

_acid_info_box() {
    # Info box.
    #
    # Using unicode box drawings here.
    # Note that we're truncating lines inside the box to 68 characters.
    #
    # Updated 2019-10-14.
    local array
    array=("$@")
    local barpad
    barpad="$(printf "━%.0s" {1..70})"
    printf "  %s%s%s  \n" "┏" "$barpad" "┓"
    for i in "${array[@]}"
    do
        printf "  ┃ %-68s ┃  \n" "${i::68}"
    done
    printf "  %s%s%s  \n\n" "┗" "$barpad" "┛"
}

_acid_install_mike() {
    # Install additional Mike-specific config files.
    # Updated 2019-11-04.
    install-dotfiles --mike
    # docker
    source_repo="git@github.com:acidgenomics/docker.git"
    target_dir="$(_acid_config_dir)/docker"
    if [[ ! -d "$target_dir" ]]
    then
        git clone --recursive "$source_repo" "$target_dir"
    fi
    # scripts-private
    source_repo="git@github.com:mjsteinbaugh/scripts-private.git"
    target_dir="$(_acid_config_dir)/scripts-private"
    if [[ ! -d "$target_dir" ]]
    then
        git clone --recursive "$source_repo"  "$target_dir"
    fi
    # Use SSH instead of HTTPS.
    (
        cd "$KOOPA_HOME" || exit 1
        git remote set-url origin "git@github.com:acidgenomics/koopa.git"
    )
}

_acid_invalid_arg() {
    # Error on invalid argument.
    # Updated 2019-10-23.
    _acid_stop "Invalid argument: '${1}'."
}

_acid_is_aws() {
    # Is the current session running on AWS?
    # Updated 2019-10-31.
    [ "$(_acid_host_type)" = "aws" ]
}

_acid_is_azure() {
    # Is the current session running on Microsoft Azure?
    # Updated 2019-10-31.
    [ "$(_acid_host_type)" = "azure" ]
}

_acid_is_conda_active() {
    # Is there a Conda environment active?
    # Updated 2019-10-20.
    [ -n "${CONDA_DEFAULT_ENV:-}" ]
}

_acid_is_darwin() {
    # Is the operating system Darwin (macOS)?
    # Updated 2019-06-22.
    [ "$(uname -s)" = "Darwin" ]
}

_acid_is_debian() {
    # Is the operating system Debian?
    # Updated 2019-10-25.
    [ -f /etc/os-release ] || return 1
    grep "ID=" /etc/os-release | grep -q "debian" ||
        grep "ID_LIKE=" /etc/os-release | grep -q "debian"
}

_acid_is_fedora() {
    # Is the operating system Fedora?
    # Updated 2019-10-25.
    [ -f /etc/os-release ] || return 1
    grep "ID=" /etc/os-release | grep -q "fedora" ||
        grep "ID_LIKE=" /etc/os-release | grep -q "fedora"
}

_acid_is_file_system_case_sensitive() {
    # Is the file system case sensitive?
    # Linux is case sensitive by default, whereas macOS and Windows are not.
    # Updated 2019-10-21.
    touch ".tmp.checkcase" ".tmp.checkCase"
    count="$(find . -maxdepth 1 -iname ".tmp.checkcase" | wc -l)"
    _acid_quiet_rm .tmp.check* 
    if [ "$count" -eq 2 ]
    then
        return 0
    else
        return 1
    fi
}

_acid_is_git() {
    # Is the current working directory a git repository?
    #
    # See also:
    # - https://stackoverflow.com/questions/2180270
    #
    # Updated 2019-10-14.
    if git rev-parse --git-dir > /dev/null 2>&1
    then
        return 0
    else
        return 1
    fi
}

_acid_is_git_clean() {
    # Is the current git repo clean, or does it have unstaged changes?
    #
    # See also:
    # - https://stackoverflow.com/questions/3878624
    # - https://stackoverflow.com/questions/3258243
    #
    # Updated 2019-10-14.

    # Are there unstaged changes?
    if ! git diff-index --quiet HEAD --
    then
        return 1
    fi
    
    # In need of a pull or push?
    if [ "$(git rev-parse HEAD)" != "$(git rev-parse '@{u}')" ]
    then
        return 1
    fi
    
    return 0
}

_acid_is_installed() {
    # Is the requested program name installed?
    # Updated 2019-10-02.
    command -v "$1" >/dev/null
}

_acid_is_interactive() {
    # Is the current shell interactive?
    # Updated 2019-06-21.
    echo "$-" | grep -q "i"
}

_acid_is_linux() {
    # Updated 2019-06-21.
    [ "$(uname -s)" = "Linux" ]
}

_acid_is_local() {
    # Is koopa installed only for the current user?
    # Updated 2019-06-25.
    echo "$KOOPA_HOME" | grep -Eq "^${HOME}"
}

_acid_is_login() {
    # Is the current shell a login shell?
    # Updated 2019-08-14.
    echo "$0" | grep -Eq "^-"
}

_acid_is_login_bash() {
    # Is the current shell a login bash shell?
    # Updated 2019-06-21.
    [ "$0" = "-bash" ]
}

_acid_is_login_zsh() {
    # Is the current shell a login zsh shell?
    # Updated 2019-06-21.
    [ "$0" = "-zsh" ]
}

_acid_is_matching_fixed() {
    # Updated 2019-10-14.
    echo "$1" | grep -Fq "$2"
}

_acid_is_matching_regex() {
    # Updated 2019-10-13.
    echo "$1" | grep -Eq "$2"
}

_acid_is_r_package_installed() {
    # Is the requested R package installed?
    # Updated 2019-10-20.
    _acid_is_installed R || return 1
    Rscript -e "\"$1\" %in% rownames(utils::installed.packages())" \
        | grep -q "TRUE"
}

_acid_is_rhel7() {
    # Is the operating system RHEL 7?
    # Updated 2019-10-25.
    [ -f /etc/os-release ] || return 1
    grep -q 'ID="rhel"' /etc/os-release || return 1
    grep -q 'VERSION_ID="7' /etc/os-release || return 1
    return 0
}

_acid_is_remote() {
    # Is the current shell session a remote connection over SSH?
    # Updated 2019-06-25.
    [ -n "${SSH_CONNECTION:-}" ]
}

_acid_is_shared() {
    # Is koopa installed for all users (shared)?
    # Updated 2019-06-25.
    ! _acid_is_local
}

_acid_is_venv_active() {
    # Is there a Python virtual environment active?
    # Updated 2019-10-20.
    [ -n "${VIRTUAL_ENV:-}" ]
}



# J                                                                         {{{1
# ==============================================================================

_acid_java_home() {
    # Set JAVA_HOME environment variable.
    #
    # See also:
    # - https://www.mkyong.com/java/
    #       how-to-set-java_home-environment-variable-on-mac-os-x/
    # - https://stackoverflow.com/questions/22290554
    #
    # Updated 2019-10-08.
    if ! _acid_is_installed java
    then
        return 0
    fi
    # Early return if environment variable is set.
    if [ -n "${JAVA_HOME:-}" ]
    then
        echo "$JAVA_HOME"
        return 0
    fi
    local home
    if _acid_is_darwin
    then
        home="$(/usr/libexec/java_home)"
    else
        local java_exe
        java_exe="$(_acid_realpath "java")"
        home="$(dirname "$(dirname "${java_exe}")")"
    fi
    echo "$home"
}



# L                                                                         {{{1
# ==============================================================================

_acid_line_count() {
    # Return the number of lines in a file.
    #
    # Example: _acid_line_count tx2gene.csv
    #
    # Updated 2019-10-27.
    wc -l "$1" \
        | xargs \
        | cut -d ' ' -f 1
}

_acid_link_cellar() {
    # Symlink cellar into build directory.
    #
    # If you run into permissions issues during link, check the build prefix
    # permissions. Ensure group is not 'root', and that group has write access.
    #
    # This can be reset easily with '_acid_set_permissions'.
    #
    # Example: _acid_link_cellar emacs 26.3
    # # '/usr/local/koopa/cellar/tmux/2.9a/*' to '/usr/local/*'.
    #
    # Updated 2019-10-22.
    local name
    local version
    local build_prefix
    local cellar_prefix
    name="$1"
    version="$2"
    build_prefix="$(_acid_build_prefix)"
    cellar_prefix="$(_acid_cellar_prefix)/${name}/${version}"
    _acid_message "Linking '${cellar_prefix}' in '${build_prefix}'."
    _acid_set_permissions "$cellar_prefix"
    if _acid_is_shared
    then
        _acid_assert_has_sudo
        sudo cp -frsv "$cellar_prefix/"* "$build_prefix/".
        _acid_update_ldconfig
    else
        cp -frsv "$cellar_prefix/"* "$build_prefix/".
    fi
}

_acid_list_path_priority() {
    # Split PATH string by ':' delim into lines.
    #
    # Bash parameter expansion:
    # > echo "${PATH//:/$'\n'}"
    #
    # Can generate a unique PATH string with:
    # > _acid_list_path_priority \
    # >     | tac \
    # >     | awk '!a[$0]++' \
    # >     | tac
    #
    # see also:
    # - https://askubuntu.com/questions/600018
    #
    # Updated 2019-10-27.
    tr ':' '\n' <<< "${1:-$PATH}"
}



# M                                                                         {{{1
# ==============================================================================

_acid_macos_app_version() {
    # Extract the version of a macOS application.
    # Updated 2019-09-28.
    _acid_assert_is_darwin
    plutil -p "/Applications/${1}.app/Contents/Info.plist" \
        | grep CFBundleShortVersionString \
        | awk -F ' => ' '{print $2}' \
        | tr -d '"'
}

_acid_major_version() {
    # Get the major program version.
    # Updated 2019-09-23.
    echo "$1" | cut -d '.' -f 1-2
}

_acid_message() {
    # General message.
    # Updated 2019-10-23.
    _acid_echo_cyan_bold "$1"
}

_acid_minor_version() {
    # Get the minor program version.
    # Updated 2019-09-23.
    echo "$1" | cut -d "." -f 2-
}

_acid_missing_arg() {
    # Error on a missing argument.
    # Updated 2019-10-23.
    _acid_stop "Missing required argument."
}



# N                                                                         {{{1
# ==============================================================================

_acid_note() {
    # General note message.
    # Updated 2019-10-23.
    _acid_echo_magenta_bold "Note: ${1}"
}



# O                                                                         {{{1
# ==============================================================================

_acid_os_type() {
    # Operating system name.
    # Always returns lowercase, with unique names for Linux distros
    # (e.g. "debian").
    # Updated 2019-10-22.
    local id
    if _acid_is_darwin
    then
        id="$(uname -s | tr '[:upper:]' '[:lower:]')"
    elif _acid_is_linux
    then
        id="$( \
            awk -F= '$1=="ID" { print $2 ;}' /etc/os-release \
            | tr -d '"' \
        )"
        # Include the major release version for RHEL.
        if [ "$id" = "rhel" ]
        then
            version="$( \
                awk -F= '$1=="VERSION_ID" { print $2 ;}' /etc/os-release \
                | tr -d '"' \
                | cut -d '.' -f 1 \
            )"
            id="${id}${version}"
        fi
    else
        id=
    fi
    echo "$id"
}

_acid_os_version() {
    # Operating system version.
    # Updated 2019-06-22.
    # Note that this returns Darwin version information for macOS.
    uname -r
}



# P                                                                         {{{1
# ==============================================================================

_acid_prefix_chgrp() {
    # Fix the group permissions on the target build prefix.
    # Updated 2019-10-22.
    local path
    local group
    path="$1"
    group="$(_acid_group)"
    if _acid_has_sudo
    then
        sudo chgrp -Rh "$group" "$path"
        sudo chmod -R g+w "$path"
    else
        chgrp -Rh "$group" "$path"
        chmod -R g+w "$path"
    fi
}

_acid_prefix_mkdir() {
    # Create directory in target build prefix.
    # Sets correct group and write permissions automatically.
    # Updated 2019-10-22.
    local path
    path="$1"
    _acid_assert_is_not_dir "$path"
    if _acid_has_sudo
    then
        sudo mkdir -p "$path"
        sudo chown "$(whoami)" "$path"
    else
        mkdir -p "$path"
    fi
    _acid_prefix_chgrp "$path"
}

_acid_prompt() {
    # Prompt string.
    #
    # Note that Unicode characters don't work well with some Windows fonts.
    #
    # User name and host.
    # - Bash : user="\u@\h"
    # - ZSH  : user="%n@%m"
    #
    # Bash: The default value is '\s-\v\$ '.
    #
    # ZSH: conda environment activation is messing up '%m'/'%M' flag on macOS.
    # This seems to be specific to macOS and doesn't happen on Linux.
    #
    # See also:
    # - https://github.com/robbyrussell/oh-my-zsh/blob/master/themes/
    #       robbyrussell.zsh-theme
    # - https://www.cyberciti.biz/tips/
    #       howto-linux-unix-bash-shell-setup-prompt.html
    # - https://misc.flogisoft.com/bash/tip_colors_and_formatting
    #
    # Updated 2019-10-31.
    local conda git newline prompt user venv wd
    user="${USER}@${HOSTNAME//.*/}"
    # Note that subshell exec need to be escaped here, so they are evaluated
    # dynamically when the prompt is refreshed.
    conda="\$(_acid_prompt_conda)"
    git="\$(_acid_prompt_git)"
    venv="\$(_acid_prompt_venv)"
    case "$KOOPA_SHELL" in
        bash)
            newline='\n'
            prompt='\$'
            wd='\w'
            ;;
        zsh)
            newline=$'\n'
            prompt='%%'
            wd='%~'
            ;;
    esac
    # Enable colorful prompt, when possible.
    if _acid_is_matching_fixed "${TERM:-}" "256color"
    then
        local conda_color git_color prompt_color user_color venv_color wd_color
        case "$KOOPA_SHELL" in
            bash)
                conda_color="33"
                git_color="32"
                prompt_color="35"
                user_color="36"
                venv_color="33"
                wd_color="34"
                # Colorize the variable strings.
                conda="\[\033[${conda_color}m\]${conda}\[\033[00m\]"
                git="\[\033[${git_color}m\]${git}\[\033[00m\]"
                prompt="\[\033[${prompt_color}m\]${prompt}\[\033[00m\]"
                user="\[\033[${user_color}m\]${user}\[\033[00m\]"
                venv="\[\033[${venv_color}m\]${venv}\[\033[00m\]"
                wd="\[\033[${wd_color}m\]${wd}\[\033[00m\]"
                ;;
            zsh)
                # SC2154: fg is referenced but not assigned.
                # shellcheck disable=SC2154
                conda_color="${fg[yellow]}"
                git_color="${fg[green]}"
                prompt_color="${fg[magenta]}"
                user_color="${fg[cyan]}"
                venv_color="${fg[yellow]}"
                wd_color="${fg[blue]}"
                # Colorize the variable strings.
                conda="%F%{${conda_color}%}${conda}%f"
                git="%F%{${git_color}%}${git}%f"
                prompt="%F%{${prompt_color}%}${prompt}%f"
                user="%F%{${user_color}%}${user}%f"
                venv="%F%{${venv_color}%}${venv}%f"
                wd="%F%{${wd_color}%}${wd}%f"
                ;;
        esac
    fi
    printf "%s%s%s%s%s%s%s%s%s " \
        "$newline" \
        "$user" "$conda" "$venv" \
        "$newline" \
        "$wd" "$git" \
        "$newline" \
        "$prompt"
}

_acid_prompt_conda() {
    # Get conda environment name for prompt string.
    # Updated 2019-10-13.
    local env
    env="$(_acid_conda_env)"
    if [ -n "$env" ]
    then
        printf " conda:%s\n" "${env}"
    else
        return 0
    fi
}

_acid_prompt_disk_used() {
    # Get current disk usage on primary drive.
    # Updated 2019-10-13.
    local pct used
    used="$(_acid_disk_pct_used)"
    case "$(_acid_shell)" in
        zsh)
            pct="%%"
            ;;
        *)
            pct="%"
            ;;
    esac
    printf " disk:%d%s\n" "$used" "$pct"
}

_acid_prompt_git() {
    # Return the current git branch, if applicable.
    # Also indicate status with "*" if dirty (i.e. has unstaged changes).
    # Updated 2019-10-14.
    _acid_is_git || return 0
    local git_branch git_status
    git_branch="$(_acid_git_branch)"
    if _acid_is_git_clean
    then
        git_status=""
    else
        git_status="*"
    fi
    printf " %s%s\n" "$git_branch" "$git_status"
}

_acid_prompt_venv() {
    # Get Python virtual environment name for prompt string.
    # https://stackoverflow.com/questions/10406926
    # Updated 2019-10-13.
    local env
    env="$(_acid_venv)"
    if [ -n "$env" ]
    then
        printf " venv:%s\n" "${env}"
    else
        return 0
    fi
}



# Q                                                                         {{{1
# ==============================================================================

_acid_quiet_cd() {
    # Updated 2019-10-29.
    cd "$@" > /dev/null || return 1
}

_acid_quiet_expr() {
    # Regular expression matching that is POSIX compliant.
    #
    # Avoid using '[[ =~ ]]' in sh config files.
    # 'expr' is faster than using 'case'.
    #
    # See also:
    # - https://stackoverflow.com/questions/21115121
    #
    # Updated 2019-10-08.
    expr "$1" : "$2" 1>/dev/null
}

_acid_quiet_rm() {
    # Quiet remove.
    # Updated 2019-10-29.
    rm -fr "$@" > /dev/null 2>&1
}



# R                                                                         {{{1
# ==============================================================================

_acid_r_home() {
    # Get 'R_HOME', rather than exporting as global variable.
    # Updated 2019-06-27.
    _acid_assert_is_installed R
    _acid_assert_is_installed Rscript
    Rscript --vanilla -e 'cat(Sys.getenv("R_HOME"))'
}

_acid_realpath() {
    # Locate the realpath of a program.
    #
    # This resolves symlinks automatically.
    # For 'which' style return, use '_acid_which' instead.
    #
    # See also:
    # - https://stackoverflow.com/questions/7665
    # - https://unix.stackexchange.com/questions/85249
    # - https://stackoverflow.com/questions/7522712
    # - https://thoughtbot.com/blog/input-output-redirection-in-the-shell
    #
    # Examples:
    # _acid_realpath bash
    # ## /usr/local/Cellar/bash/5.0.11/bin/bash
    #
    # Updated 2019-10-08.
    realpath "$(_acid_which "$1")"
}

_acid_remove_from_fpath() {
    # Remove directory from FPATH.
    # Updated 2019-10-27.
    export FPATH="${FPATH//:$1/}"
}

_acid_remove_from_manpath() {
    # Remove directory from MANPATH.
    # Updated 2019-10-14.
    export MANPATH="${MANPATH//:$1/}"
}

_acid_remove_from_path() {
    # Remove directory from PATH.
    #
    # Look into an improved POSIX method here.
    # This works for bash and ksh.
    # Note that this won't work on the first item in PATH.
    #
    # Alternate approach using sed:
    # > echo "$PATH" | sed "s|:${dir}||g"
    #
    # Updated 2019-10-14.
    export PATH="${PATH//:$1/}"
}

_acid_rsync_flags() {
    # rsync flags.
    #
    #     --delete-before         receiver deletes before xfer, not during
    #     --iconv=CONVERT_SPEC    request charset conversion of filenames
    #     --numeric-ids           don't map uid/gid values by user/group name
    #     --partial               keep partially transferred files
    #     --progress              show progress during transfer
    # -A, --acls                  preserve ACLs (implies -p)
    # -H, --hard-links            preserve hard links
    # -L, --copy-links            transform symlink into referent file/dir
    # -O, --omit-dir-times        omit directories from --times
    # -P                          same as --partial --progress
    # -S, --sparse                handle sparse files efficiently
    # -X, --xattrs                preserve extended attributes
    # -a, --archive               archive mode; equals -rlptgoD (no -H,-A,-X)
    # -g, --group                 preserve group
    # -h, --human-readable        output numbers in a human-readable format
    # -n, --dry-run               perform a trial run with no changes made
    # -o, --owner                 preserve owner (super-user only)
    # -r, --recursive             recurse into directories
    # -x, --one-file-system       don't cross filesystem boundaries    
    # -z, --compress              compress file data during the transfer
    #
    # Use '--rsync-path="sudo rsync"' to sync across machines with sudo.
    #
    # See also:
    # - https://unix.stackexchange.com/questions/165423
    #
    # Updated 2019-10-28.
    echo "--archive --delete-before --human-readable --progress"
}



# S                                                                         {{{1
# ==============================================================================

_acid_set_permissions() {
    # Set permissions on a koopa-related directory.
    # Generally used to reset the build prefix directory (e.g. '/usr/local').
    # Updated 2019-10-22.
    local path
    path="$1"
    if _acid_is_shared
    then
        sudo chown -Rh "root" "$path"
    else
        chown -Rh "$(whoami)" "$path"
    fi
    _acid_prefix_chgrp "$path"
}

_acid_shell() {
    # Note that this isn't necessarily the default shell ('$SHELL').
    # Updated 2019-06-27.
    local shell
    if [ -n "${BASH_VERSION:-}" ]
    then
        shell="bash"
    elif [ -n "${KSH_VERSION:-}" ]
    then
        shell="ksh"
    elif [ -n "${ZSH_VERSION:-}" ]
    then
        shell="zsh"
    else
        >&2 cat << EOF
Error: Failed to detect supported shell.
Supported: bash, ksh, zsh.

  SHELL: ${SHELL}
      0: ${0}
      -: ${-}
EOF
        return 1
    fi
    echo "$shell"
}

_acid_stat_access_human() {
    # Get the current access permissions in human readable form.
    # Updated 2019-10-31.
    stat -c '%A' "$1"
}

_acid_stat_access_octal() {
    # Get the current access permissions in octal form.
    # Updated 2019-10-31.
    stat -c '%a' "$1"
}

_acid_stat_group() {
    # Get the current group of a file or directory.
    # Updated 2019-10-31.
    stat -c '%G' "$1"
}

_acid_stat_user() {
    # Get the current user (owner) of a file or directory.
    # Updated 2019-10-31.
    stat -c '%U' "$1"
}

_acid_status_fail() {
    # Status FAIL.
    # Updated 2019-10-23.
    _acid_echo_red "  [FAIL] ${1}"
}

_acid_status_note() {
    # Status NOTE.
    # Updated 2019-10-23.
    _acid_echo_yellow "  [NOTE] ${1}"
}

_acid_status_ok() {
    # Status OK.
    # Updated 2019-10-23.
    _acid_echo_green "    [OK] ${1}"
}

_acid_stop() {
    # Error message.
    # Updated 2019-10-23.
    >&2 _acid_echo_red_bold "Error: ${1}"
    exit 1
}

_acid_strip_left() {
    # Strip pattern from left side (start) of string.
    #
    # Usage: _acid_lstrip "string" "pattern"
    #
    # Example: _acid_lstrip "The Quick Brown Fox" "The "
    #
    # Updated 2019-09-22.
    printf '%s\n' "${1##$2}"
}

_acid_strip_right() {
    # Strip pattern from right side (end) of string.
    #
    # Usage: _acid_rstrip "string" "pattern"
    #
    # Example: _acid_rstrip "The Quick Brown Fox" " Fox"
    #
    # Updated 2019-09-22.
    printf '%s\n' "${1%%$2}"
}

_acid_strip_trailing_slash() {
    # Strip trailing slash in file path string.
    #
    # Alternate approach using sed:
    # > sed 's/\/$//' <<< "$1"
    #
    # Updated 2019-09-24.
    _acid_strip_right "$1" "/"
}

_acid_sub() {
    # Updated 2019-10-09.
    # See also: _acid_gsub
    echo "$1" | sed -E "s/${2}/${3}/"
}

_acid_success() {
    # Success message.
    # Updated 2019-10-23.
    _acid_echo_green_bold "$1"
}



# T                                                                         {{{1
# ==============================================================================

_acid_tmp_dir() {
    # Create temporary directory.
    #
    # See also:
    # - https://stackoverflow.com/questions/4632028
    # - https://gist.github.com/earthgecko/3089509
    #
    # Note: macOS requires 'env LC_CTYPE=C'.
    # Otherwise, you'll see this error: 'tr: Illegal byte sequence'.
    # This doesn't seem to work reliably, so using timestamp instead.
    #
    # Alternate approach:
    # > local unique
    # > local dir
    # > unique="$(date "+%Y%m%d-%H%M%S")"
    # > dir="/tmp/koopa-$(id -u)-${unique}"
    # > echo "$dir"
    #
    # Updated 2019-10-17.
    mktemp -d
}

_acid_today_bucket() {
    # Create a dated file today bucket.
    # Also adds a '~/today' symlink for quick access.
    #
    # How to check if a symlink target matches a specific path:
    # https://stackoverflow.com/questions/19860345
    #
    # Useful link flags:
    # -f, --force
    #        remove existing destination files
    # -n, --no-dereference
    #        treat LINK_NAME as a normal file if it is a symbolic link to a
    #        directory
    # -s, --symbolic
    #        make symbolic links instead of hard links
    #
    # Updated 2019-11-10.
    local bucket_dir
    bucket_dir="${HOME}/bucket"
    # Early return if there's no bucket directory on the system.
    if [[ ! -d "$bucket_dir" ]]
    then
        return 0
    fi
    local today
    today="$(date +%Y-%m-%d)"
    local today_dir
    today_dir="${HOME}/today"
    # Early return if we've already updated the symlink.
    if readlink "$today_dir" | grep -q "$today"
    then
        return 0
    fi
    local bucket_today
    bucket_today="$(date +%Y)/$(date +%m)/$(date +%Y-%m-%d)"
    mkdir -p "${bucket_dir}/${bucket_today}"
    ln -fns "${bucket_dir}/${bucket_today}" "$today_dir"
}

_acid_trim_ws() {
    # Trim leading and trailing white-space from string.
    #
    # This is an alternative to sed, awk, perl and other tools. The function
    # works by finding all leading and trailing white-space and removing it from
    # the start and end of the string.
    #
    # Usage: _acid_trim_ws "   example   string    "
    #
    # Example: _acid_trim_ws "    Hello,  World    "
    #
    # Updated 2019-09-22.
    trim="${1#${1%%[![:space:]]*}}"
    trim="${trim%${trim##*[![:space:]]}}"
    printf '%s\n' "$trim"
}



# U                                                                         {{{1
# ==============================================================================

_acid_update_ldconfig() {
    # Update dynamic linker (LD) configuration.
    # Updated 2019-10-27.
    _acid_is_linux || return 0
    _acid_has_sudo || return 0
    [ -d /etc/ld.so.conf.d ] || return 0
    _acid_assert_is_installed ldconfig
    local os_type
    os_type="$(_acid_os_type)"
    local conf_source
    conf_source="${KOOPA_HOME}/os/${os_type}/etc/ld.so.conf.d"
    if [ ! -d "$conf_source" ]
    then
        _acid_stop "Source files missing: '${conf_source}'."
    fi
    # Create symlinks with "koopa-" prefix.
    # Note that we're using shell globbing here.
    # https://unix.stackexchange.com/questions/218816
    _acid_message "Updating ldconfig in '/etc/ld.so.conf.d/'."
    local source_file
    local dest_file
    for source_file in "${conf_source}/"*".conf"
    do
        dest_file="/etc/ld.so.conf.d/koopa-$(basename "$source_file")"
        sudo ln -fnsv "$source_file" "$dest_file"
    done
    sudo ldconfig
}

_acid_update_profile() {
    # Link shared 'zzz-koopa.sh' configuration file into '/etc/profile.d/'.
    # Updated 2019-11-05.
    local symlink
    _acid_is_linux || return 0
    _acid_has_sudo || return 0
    # Early return if config file already exists.
    symlink="/etc/profile.d/zzz-koopa.sh"
    [ -L "$symlink" ] && return 0
    _acid_message "Adding '${symlink}'."
    sudo rm -fv "/etc/profile.d/koopa.sh"
    sudo ln -fnsv "${KOOPA_HOME}/os/linux/etc/profile.d/zzz-koopa.sh" "$symlink"
    return 0
}

_acid_update_r_config() {
    # Add shared R configuration symlinks in '${R_HOME}/etc'.
    # Updated 2019-10-22.
    _acid_has_sudo || return 0
    _acid_is_installed R || return 0
    local r_home
    r_home="$(_acid_r_home)"
    # > local version
    # > version="$( \
    # >     R --version | \
    # >     head -n 1 | \
    # >     cut -d ' ' -f 3 | \
    # >     grep -Eo "^[0-9]+\.[0-9]+"
    # > )"
    _acid_message "Updating '${r_home}'."
    local os_type
    os_type="$(_acid_os_type)"
    local r_etc_source
    r_etc_source="${KOOPA_HOME}/os/${os_type}/etc/R"
    if [ ! -d "$r_etc_source" ]
    then
        _acid_stop "Source files missing: '${r_etc_source}'."
    fi
    sudo ln -fnsv "${r_etc_source}/"* "${r_home}/etc/".
    _acid_message "Creating site library."
    site_library="${r_home}/site-library"
    sudo mkdir -pv "$site_library"
    _acid_set_permissions "$r_home"
    _acid_r_javareconf
}

_acid_update_r_config_macos() {
    # Update R config on macOS.
    # Need to include Makevars to build packages from source.
    # Updated 2019-10-31.
    mkdir -pv "${HOME}/.R"
    ln -fnsv "/usr/local/koopa/os/darwin/etc/R/Makevars" "${HOME}/.R/."
}

_acid_update_shells() {
    # Update shell configuration.
    # Updated 2019-09-28.
    local shell
    local shell_file
    _acid_assert_has_sudo
    shell="$(_acid_build_prefix)/bin/${1}"
    shell_file="/etc/shells"
    if ! grep -q "$shell" "$shell_file"
    then
        _acid_message "Updating '${shell_file}' to include '${shell}'."
        sudo sh -c "echo ${shell} >> ${shell_file}"
    fi
    _acid_note "Run 'chsh -s ${shell} ${USER}' to change the default shell."
}

_acid_update_xdg_config() {
    # Update XDG configuration.
    # Path: '~/.config/koopa'.
    # Updated 2019-10-27.
    local config_dir
    config_dir="$(_acid_config_dir)"
    local home_dir
    home_dir="$(_acid_home)"
    local os_type
    os_type="$(_acid_os_type)"
    mkdir -pv "$config_dir"
    relink() {
        local source_file
        source_file="$1"
        local dest_file
        dest_file="$2"
        if [ ! -e "$dest_file" ]
        then
            if [ ! -e "$source_file" ]
            then
                _acid_warning "Source file missing: '${source_file}'."
                return 1
            fi
            _acid_message "Updating XDG config in '${config_dir}'."
            rm -fv "$dest_file"
            ln -fnsv "$source_file" "$dest_file"
        fi
    }
    relink "${home_dir}" "${config_dir}/home"
    relink "${home_dir}/activate" "${config_dir}/activate"
    if [ -d "${home_dir}/os/${os_type}" ]
    then
        relink "${home_dir}/os/${os_type}/etc/R" "${config_dir}/R"
    fi
}



# V                                                                         {{{1
# ==============================================================================

_acid_variable() {
    # Get version stored internally in versions.txt file.
    # Updated 2019-10-27.
    local what
    local file
    local match
    what="$1"
    file="${KOOPA_HOME}/system/include/variables.txt"
    match="$(grep -E "^${what}=" "$file" || echo "")"
    if [ -n "$match" ]
    then
        echo "$match" | cut -d "\"" -f 2
    else
        _acid_stop "'${what}' not defined in '${file}'."
    fi
}

_acid_venv() {
    local env
    if [ -n "${VIRTUAL_ENV:-}" ]
    then
        # Strip out the path and just leave the env name.
        env="${VIRTUAL_ENV##*/}"
    else
        env=
    fi
    echo "$env"
}



# W                                                                         {{{1
# ==============================================================================

_acid_warn_if_export() {
    # Warn if variable is exported in current shell session.
    # Useful for checking against unwanted compiler settings.
    # In particular, useful to check for 'LD_LIBRARY_PATH'.
    # Updated 2019-10-27.
    local arg
    for arg in "$@"
    do
        if declare -x | grep -Eq "\b${arg}\b="
        then
            _acid_warning "'${arg}' is exported."
        fi
    done
    return 0
}

_acid_warning() {
    # Warning message.
    # Updated 2019-10-23.
    >&2 _acid_echo_yellow_bold "Warning: ${1}"
}

_acid_which() {
    # Locate which program.
    #
    # Note that this intentionally doesn't resolve symlinks.
    # Use 'koopa_realpath' for that output instead.
    #
    # Example:
    # _acid_which bash
    # ## /usr/local/bin/bash
    #
    # Updated 2019-10-08.
    command -v "$1"
}



# Z                                                                         {{{1
# ==============================================================================

_acid_zsh_version() {
    # Updated 2019-08-18.
    zsh --version \
        | head -n 1 \
        | cut -d ' ' -f 2
}



# Fallback                                                                  {{{1
# ==============================================================================

# Note that this doesn't support '-ne' flag.
# > if ! _acid_is_installed echo
# > then
# >     echo() {
# >         printf "%s\n" "$1"
# >     }
# > fi

if ! _acid_is_installed realpath
then
    realpath() {
        # Real path to file/directory on disk.
        #
        # Note that 'readlink -f' doesn't work on macOS.
        #
        # See also:
        # - https://github.com/bcbio/bcbio-nextgen/blob/master/tests/
        #       run_tests.sh
        #
        # Updated 2019-06-26.
        if [ "$(uname -s)" = "Darwin" ]
        then
            perl -MCwd -e 'print Cwd::abs_path shift' "$1"
        else
            readlink -f "$@"
        fi
    }
fi

