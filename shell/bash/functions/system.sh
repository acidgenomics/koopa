#!/usr/bin/env bash

_koopa_add_local_bins_to_path() {  # {{{1
    # """
    # Add local build bins to PATH (e.g. '/usr/local').
    # @note Updated 2019-10-22.
    #
    # This will recurse through the local library and find 'bin/' subdirs.
    # Note: read '-a' flag doesn't work on macOS. zsh related?
    # """
    local dir
    local dirs
    _koopa_add_to_path_start "$(_koopa_make_prefix)/bin"
    IFS=$'\n' read -r -d '' dirs <<< "$(_koopa_bash_find_local_bin_dirs)"
    unset IFS
    for dir in "${dirs[@]}"
    do
        _koopa_add_to_path_start "$dir"
    done
    return 0
}

_koopa_find_local_bin_dirs() {  # {{{1
    # """
    # Find local bin directories.
    # @note Updated 2020-02-02.
    #
    # Alternate array sorting methods:
    # > readarray -t array < <( \
    # >     printf '%s\0' "${array[@]}" \
    # >     | sort -z \
    # >     | xargs -0n1 \
    # > )
    #
    # > IFS=$'\n' array=($(sort <<<"${array[*]}"))
    # > unset IFS
    #
    # See also:
    # - https://stackoverflow.com/questions/23356779
    # - https://stackoverflow.com/questions/7442417
    # """
    local array
    array=()
    while IFS= read -r -d $'\0'
    do
        array+=("$REPLY")
    done < <( \
        find "$(_koopa_make_prefix)" \
            -mindepth 2 \
            -maxdepth 3 \
            -type d \
            -name "bin" \
            ! -path "*/Caskroom/*" \
            ! -path "*/Cellar/*" \
            ! -path "*/Homebrew/*" \
            ! -path "*/anaconda3/*" \
            ! -path "*/bcbio/*" \
            ! -path "*/lib/*" \
            ! -path "*/miniconda3/*" \
            -print0 \
        | sort -z
    )
    printf "%s\n" "${array[@]}"
}

_koopa_git_submodule_init() {
    # """
    # Initialize git submodules.
    # @note Updated 2020-02-11.
    # """
    [[ -f ".gitmodules" ]] || return 1
    _koopa_h2 "Initializing submodules in '${PWD}'."
    _koopa_assert_is_installed git
    local array string target target_key url url_key
    git submodule init
    mapfile -t array \
        < <( \
            git config \
                -f ".gitmodules" \
                --get-regexp '^submodule\..*\.path$' \
        )
    for string in "${array[@]}"
    do
        target_key="$(echo "$string" | cut -d ' ' -f 1)"
        target="$(echo "$string" | cut -d ' ' -f 2)"
        url_key="${target_key//\.path/.url}"
        url="$(git config -f ".gitmodules" --get "$url_key")"
        _koopa_dl "$target" "$url"
        git submodule add --force "$url" "$target" > /dev/null
    done
    return 0
}

_koopa_git_pull() {
    # """
    # Pull (update) a git repository.
    # @note Updated 2020-02-11.
    # """
    _koopa_assert_is_git
    _koopa_assert_is_installed git
    git fetch --all --quiet
    git pull --quiet
    if [[ -f ".gitmodules" ]]
    then
        git submodule --quiet update --init --recursive
        git submodule --quiet foreach -q --recursive git checkout --quiet master
        git submodule --quiet foreach git pull --quiet
    fi
    return 0
}

_koopa_git_reset() {  # {{{1
    # """
    # Clean and reset a git repo and its submodules.
    # @note Updated 2020-02-11.
    #
    # Note extra '-f' flag in 'git clean' step, which handles nested '.git'
    # directories better.
    #
    # Additional steps:
    # # Ensure accidental swap files created by vim get nuked.
    # > find . -type f -name "*.swp" -delete
    # # Ensure invisible files get nuked on macOS.
    # > if _koopa_is_macos
    # > then
    # >     find . -type f -name ".DS_Store" -delete
    # > fi
    #
    # See also:
    # https://gist.github.com/nicktoumpelis/11214362
    # """
    _koopa_assert_is_git
    _koopa_assert_is_installed git
    git clean -dffx
    if [[ -f ".gitmodules" ]]
    then
        _koopa_git_submodule_init
        git submodule --quiet foreach --recursive git clean -dffx
        git reset --hard --quiet
        git submodule --quiet foreach --recursive git reset --hard --quiet
    fi
    return 0
}

_koopa_is_array_non_empty() {  # {{{1
    # """
    # Is the array non-empty?
    # @note Updated 2019-10-22.
    #
    # Particularly useful for checking against mapfile return, which currently
    # returns a length of 1 for empty input, due to newlines line break.
    # """
    local arr
    arr=("$@")
    [[ "${#arr[@]}" -eq 0 ]] && return 1
    [[ -z "${arr[0]}" ]] && return 1
    return 0
}

_koopa_r_javareconf() {  # {{{1
    # """
    # Update R Java configuration.
    # @note Updated 2020-01-24.
    #
    # The default Java path differs depending on the system.
    #
    # > R CMD javareconf -h
    #
    # Environment variables that can be used to influence the detection:
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
    # How to check that rJava works:
    # > library(rJava)
    # > .jinit()
    # """
    if ! _koopa_is_installed R
    then
        _koopa_warning "R is not installed."
        return 1
    fi
    if ! _koopa_is_installed java
    then
        _koopa_warning "java is not installed."
        return 1
    fi
    local java_home
    local java_flags
    local r_home
    java_home="$(_koopa_java_home)"
    [ -n "$java_home" ] && [ -d "$java_home" ] || return 1
    _koopa_h2 "Updating R Java configuration."
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
    if ! _koopa_is_r_package_installed rJava
    then
        Rscript -e 'install.packages("rJava")'
    fi
    return 0
}

_koopa_script_name() {  # {{{1
    # """
    # Get the calling script name.
    # @note Updated 2019-10-22.
    #
    # Note that we're using 'caller' approach, which is Bash-specific.
    # """
    local file
    file="$( \
        caller \
        | head -n 1 \
        | cut -d ' ' -f 2 \
    )"
    basename "$file"
}
