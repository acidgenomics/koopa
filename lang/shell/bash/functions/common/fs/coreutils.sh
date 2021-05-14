#!/usr/bin/env bash

koopa::cp() { # {{{1
    # """
    # Hardened version of coreutils copy.
    # @note Updated 2020-07-20.
    #
    # getopts info:
    # - http://mywiki.wooledge.org/BashFAQ/035#getopts
    # - https://wiki.bash-hackers.org/howto/getopts_tutorial
    # """
    local OPTIND cp cp_flags mkdir rm sudo symlink target_dir target_parent
    koopa::assert_is_installed cp
    sudo=0
    symlink=0
    target_dir=''
    OPTIND=1
    while getopts 'Sst:' opt
    do
        case "$opt" in
            S)
                sudo=1
                ;;
            s)
                symlink=1
                ;;
            t)
                target_dir="$OPTARG"
                ;;
            \?)
                koopa::invalid_arg
                ;;
        esac
    done
    shift "$((OPTIND-1))"
    koopa::assert_has_args "$#"
    if [[ "$sudo" -eq 1 ]]
    then
        # NOTE Don't run sudo check here, can slow down functions.
        cp=('sudo' 'cp')
        mkdir=('koopa::mkdir' '-S')
        rm=('koopa::rm' '-S')
    else
        cp=('cp')
        mkdir=('koopa::mkdir')
        rm=('koopa::rm')
    fi
    cp_flags=('-af')
    [[ "$symlink" -eq 1 ]] && cp_flags+=('-s')
    if [[ -n "$target_dir" ]]
    then
        koopa::assert_is_existing "$@"
        target_dir="$(koopa::strip_trailing_slash "$target_dir")"
        cp_flags+=('-t' "$target_dir")
        [[ -d "$target_dir" ]] || "${mkdir[@]}" "$target_dir"
    else
        koopa::assert_has_args_eq "$#" 2
        source_file="${1:?}"
        koopa::assert_is_existing "$source_file"
        target_file="${2:?}"
        [[ -e "$target_file" ]] && "${rm[@]}" "$target_file"
        target_parent="$(dirname "$target_file")"
        [[ -d "$target_parent" ]] || "${mkdir[@]}" "$target_parent"
    fi
    "${cp[@]}" "${cp_flags[@]}" "$@" &>/dev/null
    return 0
}

koopa::df() { # {{{1
    # """
    # Human friendlier version of df.
    # @note Updated 2021-05-08.
    # """
    koopa::assert_is_installed df
    df \
        --portability \
        --print-type \
        --si \
        "$@"
    return 0
}

koopa::ln() { # {{{1
    # """
    # Create a symlink quietly.
    # @note Updated 2020-07-20.
    # """
    local OPTIND ln ln_flags mkdir rm source_file target_file target_dir \
        target_parent
    koopa::assert_is_installed ln
    sudo=0
    target_dir=''
    OPTIND=1
    while getopts 'St:' opt
    do
        case "$opt" in
            S)
                sudo=1
                ;;
            t)
                target_dir="$OPTARG"
                ;;
            \?)
                koopa::invalid_arg
                ;;
        esac
    done
    shift "$((OPTIND-1))"
    koopa::assert_has_args "$#"
    if [[ "$sudo" -eq 1 ]]
    then
        # NOTE Don't run sudo check here, can slow down functions.
        ln=('sudo' 'ln')
        mkdir=('koopa::mkdir' '-S')
        rm=('koopa::rm' '-S')
    else
        ln=('ln')
        mkdir=('koopa::mkdir')
        rm=('koopa::rm')
    fi
    ln_flags=('-fns')
    if [[ -n "$target_dir" ]]
    then
        koopa::assert_is_existing "$@"
        target_dir="$(koopa::strip_trailing_slash "$target_dir")"
        ln_flags+=('-t' "$target_dir")
        [[ -d "$target_dir" ]] || "${mkdir[@]}" "$target_dir"
    else
        koopa::assert_has_args_eq "$#" 2
        source_file="${1:?}"
        koopa::assert_is_existing "$source_file"
        target_file="${2:?}"
        [[ -e "$target_file" ]] && "${rm[@]}" "$target_file"
        target_parent="$(dirname "$target_file")"
        [[ -d "$target_parent" ]] || "${mkdir[@]}" "$target_parent"
    fi
    "${ln[@]}" "${ln_flags[@]}" "$@" &>/dev/null
    return 0
}

koopa::mkdir() { # {{{1
    # """
    # Create directories with parents automatically.
    # @note Updated 2020-07-08.
    local OPTIND mkdir sudo
    sudo=0
    OPTIND=1
    while getopts 'S' opt
    do
        case "$opt" in
            S)
                sudo=1
                ;;
            \?)
                koopa::invalid_arg
                ;;
        esac
    done
    shift "$((OPTIND-1))"
    koopa::assert_has_args "$#"
    if [[ "$sudo" -eq 1 ]]
    then
        # NOTE Don't run sudo check here, can slow down functions.
        mkdir=('sudo' 'mkdir')
    else
        mkdir=('mkdir')
    fi
    "${mkdir[@]}" -p "$@" &>/dev/null
    return 0
}

koopa::mv() { # {{{1
    # """
    # Move a file or directory.
    # @note Updated 2020-07-08.
    #
    # This function works on 1 file or directory at a time.
    # It ensures that the target parent directory exists automatically.
    #
    # Useful GNU cp flags, for reference (non-POSIX):
    # - -T: no-target-directory
    # - --strip-trailing-slashes
    # """
    local OPTIND mkdir mv mv_flags rm source_file sudo target_file target_parent
    sudo=0
    target_dir=''
    OPTIND=1
    while getopts 'St:' opt
    do
        case "$opt" in
            S)
                sudo=1
                ;;
            t)
                target_dir="$OPTARG"
                ;;
            \?)
                koopa::invalid_arg
                ;;
        esac
    done
    shift "$((OPTIND-1))"
    koopa::assert_has_args "$#"
    if [[ "$sudo" -eq 1 ]]
    then
        # NOTE Don't run sudo check here, can slow down functions.
        mkdir=('koopa::mkdir' '-S')
        mv=('sudo' 'mv')
        rm=('koopa::rm' '-S')
    else
        mkdir=('koopa::mkdir')
        mv=('mv')
        rm=('koopa::rm')
    fi
    mv_flags=('-f')
    if [[ -n "$target_dir" ]]
    then
        koopa::assert_is_existing "$@"
        target_dir="$(koopa::strip_trailing_slash "$target_dir")"
        mv_flags+=('-t' "$target_dir")
        [[ -d "$target_dir" ]] || "${mkdir[@]}" "$target_dir"
    else
        koopa::assert_has_args_eq "$#" 2
        source_file="$(koopa::strip_trailing_slash "${1:?}")"
        koopa::assert_is_existing "$source_file"
        target_file="$(koopa::strip_trailing_slash "${2:?}")"
        [[ -e "$target_file" ]] && "${rm[@]}" "$target_file"
        target_parent="$(dirname "$target_file")"
        [[ -d "$target_parent" ]] || "${mkdir[@]}" "$target_parent"
    fi
    "${mv[@]}" "${mv_flags[@]}" "$@" &>/dev/null
    return 0
}

koopa::relink() { # {{{1
    # """
    # Re-create a symbolic link dynamically, if broken.
    # @note Updated 2020-07-07.
    # """
    local OPTIND dest_file ln rm source_file sudo
    sudo=0
    OPTIND=1
    while getopts 'S' opt
    do
        case "$opt" in
            S)
                sudo=1
                ;;
            \?)
                koopa::invalid_arg
                ;;
        esac
    done
    shift "$((OPTIND-1))"
    koopa::assert_has_args_eq "$#" 2
    if [[ "$sudo" -eq 1 ]]
    then
        ln=('koopa::ln' '-S')
        rm=('koopa::rm' '-S')
    else
        ln=('koopa::ln')
        rm=('koopa::rm')
    fi
    source_file="${1:?}"
    dest_file="${2:?}"
    # Keep this check relaxed, in case dotfiles haven't been cloned.
    [[ -e "$source_file" ]] || return 0
    [[ -L "$dest_file" ]] && return 0
    "${rm[@]}" "$dest_file"
    "${ln[@]}" "$source_file" "$dest_file"
    return 0
}

koopa::rm() { # {{{1
    # """
    # Remove files/directories quietly.
    # @note Updated 2020-07-06.
    # """
    local OPTIND rm sudo
    sudo=0
    OPTIND=1
    while getopts 'S' opt
    do
        case "$opt" in
            S)
                sudo=1
                ;;
            \?)
                koopa::invalid_arg
                ;;
        esac
    done
    shift "$((OPTIND-1))"
    koopa::assert_has_args "$#"
    if [[ "$sudo" -eq 1 ]]
    then
        # NOTE Don't run sudo check here, can slow down functions.
        rm=('sudo' 'rm')
    else
        rm=('rm')
    fi
    "${rm[@]}" -fr "$@" &>/dev/null
    return 0
}

