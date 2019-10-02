#!/usr/bin/env bash



# A                                                                         {{{1
# ==============================================================================

# Add local builds to PATH (e.g. '/usr/local').
#
# This will recurse through the local library and find 'bin/' subdirs.
#
# Note: read `-a` flag doesn't work on macOS. zsh related?
#
# Updated 2019-06-20.
_koopa_add_local_bins_to_path() {
    local dir
    local dirs
    _koopa_add_to_path_start "$(_koopa_build_prefix)/bin"
    IFS=$'\n'
    read -r -d '' dirs <<< "$(_koopa_bash_find_local_bin_dirs)"
    unset IFS
    for dir in "${dirs[@]}"
    do
        _koopa_add_to_path_start "$dir"
    done
}



# F                                                                         {{{1
# ==============================================================================

# Find local bin directories.
#
# See also:
# - https://stackoverflow.com/questions/23356779
# - https://stackoverflow.com/questions/7442417
#
# Modified 2019-09-11.
_koopa_find_local_bin_dirs() {
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
    # > local sorted
    # SC2207: Prefer mapfile or read -a to split command output.
    # > IFS=$'\n' mapfile -t array < <(sort <<<"${array[*]}")
    # > unset IFS
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



# Help header string.
# Updated 2019-09-30.
_koopa_help_header() {
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



# J                                                                         {{{1
# ==============================================================================

# Set JAVA_HOME environment variable.
#
# See also:
# - https://www.mkyong.com/java/how-to-set-java_home-environment-variable-on-mac-os-x/
# - https://stackoverflow.com/questions/22290554
#
# Updated 2019-10-02.
_koopa_java_home() {
    _koopa_assert_is_installed java
    # Early return if environment variable is set.
    if [ -n "${JAVA_HOME:-}" ]
    then
        echo "$JAVA_HOME"
        return 0
    fi
    local home
    if _koopa_is_darwin
    then
        home="$(/usr/libexec/java_home)"
    else
        local java_exe
        java_exe="$(_koopa_locate "java")"
        home="$(dirname "$(dirname "${java_exe}")")"
    fi
    echo "$home"
}



# L                                                                         {{{1
# ==============================================================================

# Locate the realpath of a program.
#
# This resolves symlinks automatically.
# For 'which' style return, use '_koopa_which' instead.
#
# See also:
# - https://stackoverflow.com/questions/7522712
# - https://thoughtbot.com/blog/input-output-redirection-in-the-shell
#
# Examples:
# _koopa_locate bash
# ## /usr/local/Cellar/bash/5.0.11/bin/bash
#
# Updated 2019-10-02.
_koopa_locate() {
    local command
    command="$1"
    local which
    which="$(_koopa_which "$command")"
    local path
    path="$(realpath "$which")"
    echo "$path"
}



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
# # Updated 2019-10-02.
_koopa_r_javareconf() {
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

# Get the calling script name.
# Updated 2019-09-25.
_koopa_script_name() {
    local file
    file="$( \
        caller | \
        head -n 1 | \
        cut -d ' ' -f 2 \
    )"
    basename "$file"
}



# W                                                                         {{{1
# ==============================================================================

# Locate which program.
#
# Note that this intentionally doesn't resolve symlinks.
# Use 'koopa_locate' for that instead.
#
# Not currently working for zsh.
# 'command -v' doesn't return anything back inside a function.
# Also tried:
# - 'type -p'
# - 'whence -p'
#
# Examples:
# _koopa_which bash
# ## /usr/local/bin/bash
#
# Updated 2019-10-02.
_koopa_which() {
    local command
    command="$1"
    local path
    path="$(command -v "$command")"
    if [ -z "$path" ]
    then
        >&2 printf "Warning: Failed to locate '%s'.\n" "$command"
        return 1
    fi
    echo "$path"
}
