#!/usr/bin/env bash



# A                                                                         {{{1
# ==============================================================================

_koopa_add_local_bins_to_path() {
    # Add local build bins to PATH (e.g. '/usr/local').
    #
    # This will recurse through the local library and find 'bin/' subdirs.
    # Note: read `-a` flag doesn't work on macOS. zsh related?
    #
    # Updated 2019-10-22.
    local dir
    local dirs
    _koopa_add_to_path_start "$(_koopa_build_prefix)/bin"
    IFS=$'\n' read -r -d '' dirs <<< "$(_koopa_bash_find_local_bin_dirs)"
    unset IFS
    for dir in "${dirs[@]}"
    do
        _koopa_add_to_path_start "$dir"
    done
}



# B                                                                         {{{1
# ==============================================================================

_koopa_build_os_string() {
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
    if _koopa_is_darwin
    then
        string="${mach}-${OSTYPE}"
    else
        os_type="$(_koopa_os_type)"
        if echo "$os_type" | grep -q "rhel"
        then
            os_type="redhat"
        fi
        string="${mach}-${os_type}-${OSTYPE}"
    fi
    echo "$string"
}

_koopa_build_set_permissions() {
    # Set permissions on program built from source.
    # Updated 2019-06-27.
    local path
    path="$1"
    if _koopa_has_sudo
    then
        sudo chown -Rh "root" "$path"
    else
        chown -Rh "$(whoami)" "$path"
    fi
    _koopa_prefix_chgrp "$path"
}



# C                                                                         {{{1
# ==============================================================================

_koopa_cellar_prefix() {
    # Avoid setting to `/usr/local/cellar`, as this can conflict with Homebrew.
    # Updated 2019-09-27.
    local prefix
    if [[ -w "$KOOPA_HOME" ]]
    then
        prefix="${KOOPA_HOME}/cellar"
    else
        if [[ -z "${XDG_DATA_HOME:-}" ]]
        then
            >&2 printf "Warning: 'XDG_DATA_HOME' is unset.\n"
            XDG_DATA_HOME="${HOME}/.local/share"
        fi
        prefix="${XDG_DATA_HOME}/koopa/cellar"
    fi
    echo "$prefix"
}

_koopa_cellar_script() {
    # Updated 2019-10-08.
    _koopa_assert_has_no_environments
    local name
    name="$1"
    file="${KOOPA_HOME}/system/include/cellar/${name}.sh"
    _koopa_assert_is_file "$file"
    echo "$file"
}

_koopa_conda_env_prefix() {
    # Return prefix for a specified conda environment.
    #
    # Note that we're allowing env_list passthrough as second positional
    # variable, to speed up loading upon activation.
    #
    # Updated 2019-10-18.
    _koopa_is_installed conda || return 1

    local env_name
    env_name="$1"
    [[ -n "$env_name" ]] || return 1

    local env_list
    env_list="${2:-}"
    if [[ -z "$env_list" ]]
    then
        env_list="$(_koopa_conda_env_list)"
    fi
    env_list="$(echo "$env_list" | grep "$env_name")"
    if [[ -z "$env_list" ]]
    then
        >&2 printf "Error: Failed to detect prefix for '%s'.\n" "$env_name"
        return 1
    fi

    local path
    path="$( \
        echo "$env_list" | \
        grep "/envs/${env_name}" | \
        head -n 1 \
    )"
    echo "$path" | sed -E 's/^.*"(.+)".*$/\1/'
}



# F                                                                         {{{1
# ==============================================================================

_koopa_find_local_bin_dirs() {
    # Find local bin directories.
    #
    # See also:
    # - https://stackoverflow.com/questions/23356779
    # - https://stackoverflow.com/questions/7442417
    #
    # Updated 2019-10-22.
    local array
    array=()
    local tmp_file
    tmp_file="$(_koopa_tmp_dir)/find"
    find "$(_koopa_build_prefix)" \
        -mindepth 2 \
        -maxdepth 3 \
        -name "bin" \
        ! -path "*/Caskroom/*" \
        ! -path "*/Cellar/*" \
        ! -path "*/Homebrew/*" \
        ! -path "*/anaconda3/*" \
        ! -path "*/bcbio/*" \
        ! -path "*/lib/*" \
        ! -path "*/miniconda3/*" \
        -print0 > "$tmp_file"
    while IFS=  read -r -d $'\0'
    do
        array+=("$REPLY")
    done < "$tmp_file"
    rm -f "$tmp_file"
    # Sort the array.
    # > IFS=$'\n' array=($(sort <<<"${array[*]}"))
    # > unset IFS
    readarray -t array < <(printf '%s\0' "${array[@]}" | sort -z | xargs -0n1)
    printf "%s\n" "${array[@]}"
}



# H                                                                         {{{1
# ==============================================================================

_koopa_help_args() {
cat << EOF
help arguments:
    --help, -h
        Show this help message and exit.
EOF
}

_koopa_help_header() {
    # Help header string.
    # Updated 2019-09-30.
    local name
    name="${1:-}"
    if [[ -z "$name" ]]
    then
        local file
        file="$( \
            caller | \
            head -n 1 | \
            cut -d ' ' -f 2 \
        )"
        name="$(basename "$file")"
    fi
    printf "usage: %s [--help|-h]" "$name"
}



# L                                                                         {{{1
# ==============================================================================

_koopa_is_array_non_empty() {
    # Is the array non-empty?
    # Particularly useful for checking against mapfile return, which currently
    # returns a length of 1 for empty input, due to newlines line break.
    # Updated 2019-10-22.
    local arr
    arr=("$@")
    [[ "${#arr[@]}" -eq 0 ]] && return 1
    [[ -z "${arr[0]}" ]] && return 1
    return 0
}



# L                                                                         {{{1
# ==============================================================================

_koopa_link_cellar() {
    # Symlink cellar into build directory.
    # e.g. '/usr/local/koopa/cellar/tmux/2.9a/*' to '/usr/local/*'.
    #
    # Example: _koopa_link_cellar emacs 26.3
    #
    # Updated 2019-10-08.
    local name
    local version
    local build_prefix
    local cellar_prefix
    name="$1"
    version="$2"
    build_prefix="$(_koopa_build_prefix)"
    cellar_prefix="$(_koopa_cellar_prefix)/${name}/${version}"
    printf "Linking %s in %s.\n" "$cellar_prefix" "$build_prefix"
    # > _koopa_build_set_permissions "$build_prefix"
    _koopa_build_set_permissions "$cellar_prefix"
    if _koopa_is_shared
    then
        _koopa_assert_has_sudo
        sudo cp -frsv "$cellar_prefix/"* "$build_prefix/".
        _koopa_update_ldconfig
    else
        cp -frsv "$cellar_prefix/"* "$build_prefix/".
    fi
}



# P                                                                         {{{1
# ==============================================================================

_koopa_prefix_chgrp() {
    # Fix the group permissions on the build directory.
    # Updated 2019-09-27.
    local path
    local group
    path="$1"
    group="$(_koopa_prefix_group)"
    if _koopa_has_sudo
    then
        sudo chgrp -Rh "$group" "$path"
        sudo chmod -R g+w "$path"
    else
        chgrp -Rh "$group" "$path"
        chmod -R g+w "$path"
    fi
}

_koopa_prefix_group() {
    # Set the admin or regular user group automatically.
    # Updated 2019-09-27.
    local group
    if _koopa_is_shared && _koopa_has_sudo
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

_koopa_prefix_mkdir() {
    # Create directory in build prefix.
    # Updated 2019-09-27.
    local path
    path="$1"
    _koopa_assert_is_not_dir "$path"
    if _koopa_has_sudo
    then
        sudo mkdir -p "$path"
        sudo chown "$(whoami)" "$path"
    else
        mkdir -p "$path"
    fi
    _koopa_prefix_chgrp "$path"
}



# R                                                                         {{{1
# ==============================================================================

_koopa_r_javareconf() {
    # Update rJava configuration.
    # The default Java path differs depending on the system.
    # # > R CMD javareconf -h
    # # Environment variables that can be used to influence the detection:
    #   JAVA           path to a Java interpreter executable
    #                  By default first 'java' command found on the PATH
    #                  is taken (unless JAVA_HOME is also specified).
    #   JAVA_HOME      home of the Java environment. If not specified,
    #                  it will be detected automatically from the Java
    #                  interpreter.
    #   JAVAC          path to a Java compiler
    #   JAVAH          path to a Java header/stub generator
    #   JAR            path to a Java archive tool
    #
    # Updated 2019-10-02.
    _koopa_assert_is_installed R
    _koopa_assert_is_installed java
    local java_home
    local java_flags
    local r_home
    java_home="$(_koopa_java_home)"
    [ -n "$java_home" ] && [ -d "$java_home" ] || return 1
    printf "Updating R Java configuration.\n"
    java_flags=(
        "JAVA_HOME=${java_home}" \
        "JAVA=${java_home}/bin/java" \
        "JAVAC=${java_home}/bin/javac" \
        "JAVAH=${java_home}/bin/javah" \
        "JAR=${java_home}/bin/jar" \
    )
    r_home="$(_koopa_r_home)"
    _koopa_build_set_permissions "$r_home"
    R --vanilla CMD javareconf "${java_flags[@]}"
    if _koopa_has_sudo
    then
        sudo R --vanilla CMD javareconf "${java_flags[@]}"
    fi
    Rscript -e 'install.packages("rJava")'
}



# S                                                                         {{{1
# ==============================================================================

_koopa_script_name() {
    # Get the calling script name.
    # Note that this 'caller' approach works in Bash.
    # Updated 2019-09-25.
    local file
    file="$( \
        caller | \
        head -n 1 | \
        cut -d ' ' -f 2 \
    )"
    basename "$file"
}
