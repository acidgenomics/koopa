#!/bin/sh

koopa_msigdb_prefix() {
    # """
    # MSigDB prefix.
    # @note Updated 2020-05-05.
    # """
    koopa_print "$(koopa_refdata_prefix)/msigdb"
    return 0
}

koopa_monorepo_prefix() {
    # """
    # Git monorepo prefix.
    # @note Updated 2020-07-03.
    # """
    koopa_print "${HOME:?}/monorepo"
    return 0
}

koopa_nim_packages_prefix() {
    # """
    # Nim (Nimble) packages prefix.
    # @note Updated 2021-09-29.
    #
    # @usage koopa_nim_packages_prefix [VERSION]
    # """
    __koopa_packages_prefix 'nim' "$@"
}

koopa_node_packages_prefix() {
    # """
    # Node.js (NPM) packages prefix.
    # @note Updated 2021-05-25.
    #
    # @usage koopa_node_packages_prefix [VERSION]
    # """
    __koopa_packages_prefix 'node' "$@"
}

koopa_openjdk_prefix() {
    # """
    # OpenJDK prefix.
    # @note Updated 2020-11-19.
    # """
    koopa_print "$(koopa_opt_prefix)/openjdk"
    return 0
}

koopa_opt_prefix() {
    # """
    # Custom application install prefix.
    # @note Updated 2021-05-17.
    # """
    koopa_print "$(koopa_koopa_prefix)/opt"
    return 0
}

koopa_os_codename() {
    # """
    # Operating system codename.
    # @note Updated 2021-06-02.
    # """
    if koopa_is_debian_like
    then
        koopa_debian_os_codename
    elif koopa_is_macos
    then
        koopa_macos_os_codename
    else
        return 1
    fi
    return 0
}

koopa_os_id() {
    # """
    # Operating system ID.
    # @note Updated 2021-05-21.
    #
    # Just return the OS platform ID (e.g. debian).
    # """
    local x
    x="$( \
        koopa_os_string \
        | cut -d '-' -f '1' \
    )"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_os_string() {
    # """
    # Operating system string.
    # @note Updated 2022-02-23.
    #
    # Alternatively, use 'hostnamectl'.
    # https://linuxize.com/post/how-to-check-linux-version/
    #
    # If we ever add Windows support, look for: cygwin, mingw32*, msys*.
    # """
    local id release_file string version
    if koopa_is_macos
    then
        id='macos'
        version="$(koopa_macos_os_version)"
        version="$(koopa_major_minor_version "$version")"
    elif koopa_is_linux
    then
        release_file='/etc/os-release'
        if [ -r "$release_file" ]
        then
            # shellcheck disable=SC2016
            id="$( \
                awk -F= '$1=="ID" { print $2 ;}' "$release_file" \
                | tr -d '"' \
            )"
            # Include the major release version.
            # shellcheck disable=SC2016
            version="$( \
                awk -F= '$1=="VERSION_ID" { print $2 ;}' "$release_file" \
                | tr -d '"'
            )"
            if [ -n "$version" ]
            then
                version="$(koopa_major_version "$version")"
            else
                # This is the case for Arch Linux.
                version='rolling'
            fi
        else
            id='linux'
        fi
    fi
    [ -z "$id" ] && return 1
    string="$id"
    if [ -n "${version:-}" ]
    then
        string="${string}-${version}"
    fi
    koopa_print "$string"
    return 0
}

koopa_perl_packages_prefix() {
    # """
    # Perl site library prefix.
    # @note Updated 2021-06-11.
    #
    # @usage koopa_perl_packages_prefix [VERSION]
    #
    # @seealso
    # > perl -V
    # # Inspect the '@INC' variable.
    # """
    __koopa_packages_prefix 'perl' "$@"
}

koopa_perlbrew_prefix() {
    # """
    # Perlbrew prefix.
    # @note Updated 2021-05-25.
    # """
    koopa_print "$(koopa_opt_prefix)/perlbrew"
    return 0
}

koopa_pipx_prefix() {
    # """
    # pipx prefix.
    # @note Updated 2021-05-25.
    # """
    koopa_print "$(koopa_opt_prefix)/pipx"
    return 0
}

koopa_prelude_emacs_prefix() {
    # """
    # Prelude Emacs prefix.
    # @note Updated 2021-06-07.
    # """
    koopa_print "$(koopa_xdg_data_home)/prelude"
    return 0
}

koopa_print() {
    # """
    # Print a string.
    # @note Updated 2020-07-05.
    #
    # printf vs. echo
    # - http://www.etalabs.net/sh_tricks.html
    # - https://unix.stackexchange.com/questions/65803
    # - https://www.freecodecamp.org/news/
    #       how-print-newlines-command-line-output/
    # """
    local string
    if [ "$#" -eq 0 ]
    then
        printf '\n'
        return 0
    fi
    for string in "$@"
    do
        printf '%b\n' "$string"
    done
    return 0
}

koopa_prompt_conda() {
    # """
    # Get conda environment name for prompt string.
    # @note Updated 2021-08-17.
    # """
    local env
    env="$(koopa_conda_env_name)"
    [ -n "$env" ] || return 0
    koopa_print " conda:${env}"
    return 0
}

koopa_prompt_git() {
    # """
    # Return the current git branch, if applicable.
    # @note Updated 2021-08-19.
    #
    # Also indicate status with '*' if dirty (i.e. has unstaged changes).
    # """
    local git_branch git_status
    koopa_is_git_repo || return 0
    git_branch="$(koopa_git_branch)"
    if koopa_is_git_repo_clean
    then
        git_status=''
    else
        git_status='*'
    fi
    koopa_print " ${git_branch}${git_status}"
    return 0
}

koopa_prompt_python_venv() {
    # """
    # Get Python virtual environment name for prompt string.
    # @note Updated 2021-06-14.
    #
    # See also: https://stackoverflow.com/questions/10406926
    # """
    local env
    env="$(koopa_python_venv_name)"
    [ -n "$env" ] || return 0
    koopa_print " venv:${env}"
    return 0
}

koopa_pyenv_prefix() {
    # """
    # Python pyenv prefix.
    # @note Updated 2021-05-25.
    #
    # See also approach used for rbenv.
    # """
    koopa_print "$(koopa_opt_prefix)/pyenv"
    return 0
}

# > koopa_python_packages_prefix() {
# >     # """
# >     # Python site packages library prefix.
# >     # @note Updated 2021-06-11.
# >     #
# >     # @usage koopa_python_packages_prefix [VERSION]
# >     #
# >     # @seealso
# >     # > "$python" -m site
# >     # """
# >     __koopa_packages_prefix 'python' "$@"
# > }

koopa_python_venv_name() {
    # """
    # Python virtual environment name.
    # @note Updated 2021-08-17.
    # """
    local x
    x="${VIRTUAL_ENV:-}"
    [ -n "$x" ] || return 1
    # Strip out the path and just leave the env name.
    x="${x##*/}"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}

koopa_python_virtualenvs_prefix() {
    # """
    # Python virtual environment prefix.
    # @note Updated 2022-03-30.
    # """
    koopa_print "$(koopa_opt_prefix)/python-virtualenvs"
    return 0
}

koopa_r_packages_prefix() {
    # """
    # R site library prefix.
    # @note Updated 2021-06-11.
    #
    # @usage koopa_r_packages_prefix [VERSION]
    # """
    __koopa_packages_prefix 'r' "$@"
}

koopa_rbenv_prefix() {
    # """
    # Ruby rbenv prefix.
    # @note Updated 2021-05-25.
    # ""
    koopa_print "$(koopa_opt_prefix)/rbenv"
    return 0
}

koopa_refdata_prefix() {
    # """
    # Reference data prefix.
    # @note Updated 2021-12-09.
    # """
    koopa_print "$(koopa_opt_prefix)/refdata"
    return 0
}

koopa_ruby_packages_prefix() {
    # """
    # Ruby packags (gems) prefix.
    # @note Updated 2021-05-25.
    #
    # @usage koopa_ruby_packages_prefix [VERSION]
    # """
    __koopa_packages_prefix 'ruby' "$@"
}

koopa_rust_prefix() {
    # """
    # Rust (rustup) install prefix.
    # @note Updated 2021-05-25.
    # """
    koopa_print "$(koopa_opt_prefix)/rust"
    return 0
}

koopa_rust_packages_prefix() {
    # """
    # Rust packags prefix.
    # @note Updated 2022-04-09.
    #
    # @usage koopa_rust_packages_prefix [VERSION]
    # """
    __koopa_packages_prefix 'rust' "$@"
}

koopa_sbin_prefix() {
    # """
    # Koopa super user binary prefix.
    # @note Updated 2022-04-05.
    # """
    koopa_print "$(koopa_koopa_prefix)/sbin"
    return 0
}

koopa_scripts_private_prefix() {
    # """
    # Private scripts prefix.
    # @note Updated 2020-02-15.
    # """
    koopa_print "$(koopa_config_prefix)/scripts-private"
    return 0
}

koopa_shell_name() {
    # """
    # Current shell name.
    # @note Updated 2021-05-25.
    # """
    local shell str
    shell="$(koopa_locate_shell)"
    str="$(basename "$shell")"
    [ -n "$str" ] || return 1
    koopa_print "$str"
    return 0
}

koopa_spacemacs_prefix() {
    # """
    # Spacemacs prefix.
    # @note Updated 2021-06-07.
    # """
    koopa_print "$(koopa_xdg_data_home)/spacemacs"
    return 0
}

koopa_spacevim_prefix() {
    # """
    # SpaceVim prefix.
    # @note Updated 2021-06-07.
    # """
    koopa_print "$(koopa_xdg_data_home)/spacevim"
    return 0
}

koopa_str_detect_posix() {
    # """
    # Evaluate whether a string contains a desired value.
    # @note Updated 2022-02-15.
    #
    # We're unsetting 'test' here to ensure no variables/functions mask the
    # shell built-in.
    # """
    unset test
    test "${1#*"$2"}" != "$1"
}

koopa_today() {
    # """
    # Today string.
    # @note Updated 2021-05-26.
    # """
    local str
    str="$(date '+%Y-%m-%d')"
    [ -n "$str" ] || return 1
    koopa_print "$str"
    return 0
}

koopa_umask() {
    # """
    # Set default file permissions.
    # @note Updated 2020-06-03.
    #
    # - 'umask': Files and directories.
    # - 'fmask': Only files.
    # - 'dmask': Only directories.
    #
    # Use 'umask -S' to return 'u,g,o' values.
    #
    # - 0022: 'u=rwx,g=rx,o=rx'.
    #         User can write, others can read. Usually default.
    # - 0002: 'u=rwx,g=rwx,o=rx'.
    #         User and group can write, others can read.
    #         Recommended setting in a shared coding environment.
    # - 0077: 'u=rwx,g=,o='.
    #         User alone can read/write. More secure.
    #
    # Access control lists (ACLs) are sometimes preferable to umask.
    #
    # Here's how to use ACLs with setfacl.
    # > setfacl -d -m group:name:rwx /dir
    #
    # @seealso
    # - https://stackoverflow.com/questions/13268796
    # - https://askubuntu.com/questions/44534
    # """
    umask 0002
    return 0
}

koopa_user() {
    # """
    # Current user name.
    # @note Updated 2020-06-30.
    #
    # Alternatively, can use 'whoami' here.
    # """
    __koopa_id -un
    return 0
}

koopa_user_id() {
    # """
    # Current user ID.
    # @note Updated 2020-04-16.
    # """
    __koopa_id -u
    return 0
}

koopa_xdg_cache_home() {
    # """
    # XDG cache home.
    # @note Updated 2021-05-20.
    # """
    local x
    x="${XDG_CACHE_HOME:-}"
    if [ -z "$x" ]
    then
        x="${HOME:?}/.cache"
    fi
    koopa_print "$x"
    return 0
}

koopa_xdg_config_dirs() {
    # """
    # XDG config dirs.
    # @note Updated 2021-05-20.
    # """
    local x
    x="${XDG_CONFIG_DIRS:-}"
    if [ -z "$x" ] 
    then
        x='/etc/xdg'
    fi
    koopa_print "$x"
    return 0
}

koopa_xdg_config_home() {
    # """
    # XDG config home.
    # @note Updated 2021-05-20.
    # """
    local x
    x="${XDG_CONFIG_HOME:-}"
    if [ -z "$x" ]
    then
        x="${HOME:?}/.config"
    fi
    koopa_print "$x"
    return 0
}

