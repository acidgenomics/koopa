#!/usr/bin/env bash



# A                                                                         {{{1
# ==============================================================================

_koopa_add_local_bins_to_path() {
    # Add local build bins to PATH (e.g. '/usr/local').
    #
    # This will recurse through the local library and find 'bin/' subdirs.
    # Note: read '-a' flag doesn't work on macOS. zsh related?
    #
    # Updated 2019-10-22.
    local dir
    local dirs
    _koopa_add_to_path_start "$(_koopa_make_prefix)/bin"
    IFS=$'\n' read -r -d '' dirs <<< "$(_koopa_bash_find_local_bin_dirs)"
    unset IFS
    for dir in "${dirs[@]}"
    do
        _koopa_add_to_path_start "$dir"
    done
}



# D                                                                         {{{1
# ==============================================================================

_koopa_die() {
    # Die with a stack trace, via caller.
    #
    # > help caller
    # caller: caller [expr]
    # Return the context of the current subroutine call.
    #
    # Without EXPR, returns "$line $filename".  With EXPR, returns
    # "$line $subroutine $filename"; this extra information can be used to
    # provide a stack trace.
    #
    # The value of EXPR indicates how many call frames to go back before the
    # current one; the top frame is frame 0.
    #
    # See also:
    # - https://unix.stackexchange.com/a/250533
    #
    # Updated 2019-11-05.
    local frame=0
    while caller $frame
    do
        ((frame++))
    done
    echo "$*"
    exit 1
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
    find "$(_koopa_make_prefix)" \
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
    _koopa_quiet_rm "$tmp_file"
    # Sort the array.
    # > IFS=$'\n' array=($(sort <<<"${array[*]}"))
    # > unset IFS
    readarray -t array < <(printf '%s\0' "${array[@]}" | sort -z | xargs -0n1)
    printf "%s\n" "${array[@]}"
}



# H                                                                         {{{1
# ==============================================================================

_koopa_help() {
    # Show usage via help flag.
    #
    # Now always calls 'man' to display nicely formatted manual page.
    #
    # Alternate approach:
    # > path="${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}"
    #
    # See also:
    # - https://stackoverflow.com/questions/192319
    #
    # Updated 2019-11-11.
    case "${1:-}" in
        --help|-h)
            local name path
            path="$0"
            name="${path##*/}"
            man "$name"
            exit 0
            ;;
    esac
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
    # Updated 2019-11-05.
    _koopa_assert_is_installed R java
    local java_home
    local java_flags
    local r_home
    java_home="$(_koopa_java_home)"
    [ -n "$java_home" ] && [ -d "$java_home" ] || return 1
    _koopa_message "Updating R Java configuration."
    java_flags=(
        "JAVA_HOME=${java_home}"
        "JAVA=${java_home}/bin/java"
        "JAVAC=${java_home}/bin/javac"
        "JAVAH=${java_home}/bin/javah"
        "JAR=${java_home}/bin/jar"
    )
    r_home="$(_koopa_r_home)"
    _koopa_set_permissions "$r_home"
    R --vanilla CMD javareconf "${java_flags[@]}"
    # > if _koopa_is_shared_install
    # > then
    # >     _koopa_assert_has_sudo
    # >     sudo R --vanilla CMD javareconf "${java_flags[@]}"
    # > fi
    Rscript -e 'install.packages("rJava")'
}



# S                                                                         {{{1
# ==============================================================================

_koopa_script_name() {
    # Get the calling script name.
    # Note that we're using 'caller' approach, which is Bash-specific.
    # Updated 2019-10-22.
    local file
    file="$( \
        caller \
        | head -n 1 \
        | cut -d ' ' -f 2 \
    )"
    basename "$file"
}



# Fallback                                                                  {{{1
# ==============================================================================

# print is a useful zsh built-in but not defined in bash.

print() {
    echo ""
}
