#!/usr/bin/env bash

koopa::cd() { # {{{1
    # """
    # Change directory quietly.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args_eq "$#" 1
    cd "${1:?}" >/dev/null || return 1
    return 0
}

koopa::cp() { # {{{1
    # """
    # Hardened version of coreutils copy.
    # @note Updated 2020-07-05.
    #
    # getopts info:
    # - http://mywiki.wooledge.org/BashFAQ/035#getopts
    # - https://wiki.bash-hackers.org/howto/getopts_tutorial
    # """
    local OPTIND cp cp_flags mkdir rm sudo target_dir
    koopa::assert_has_args "$#"
    koopa::assert_is_installed cp
    sudo=0
    target_dir=
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
                koopa::stop "Invalid option: -${OPTARG}"
            ;;
        esac
    done
    shift "$((OPTIND-1))"
    if [[ "$sudo" -eq 1 ]]
    then
        cp=('sudo' 'cp')
        mkdir=('koopa::mkdir' '-S')
        rm=('koopa::rm' '-S')
    else
        cp=('cp')
    fi
    cp_flags=('-af')
    if [[ -n "$target_dir" ]]
    then
        koopa::assert_is_existing "$@"
        cp_flags+=('-t' "$target_dir")
        "${mkdir[@]}" "$target_dir"
    else
        koopa::assert_has_args_eq "$#" 2
        source_file="${1:?}"
        koopa::assert_is_existing "$source_file"
        target_file="${2:?}"
        [[ -e "$target_file" ]] && "${rm[@]}" "$target_file"
        "${mkdir[@]}" "$(dirname "$target_file")"
    fi
    "${cp[@]}" "${cp_flags[@]}" "$@"
    return 0
}

koopa::ln() { # {{{1
    # """
    # Create a symlink quietly.
    # @note Updated 2020-07-06.
    # """
    local OPTIND ln rm source_file target_file
    koopa::assert_has_args_eq "$#" 2
    koopa::assert_is_installed ln
    OPTIND=1
    while getopts 'S' opt
    do
        case "$opt" in
            S)
                sudo=1
                ;;
            \?)
                koopa::stop "Invalid option: -${OPTARG}"
            ;;
        esac
    done
    shift "$((OPTIND-1))"
    if [[ "$sudo" -eq 1 ]]
    then
        ln=('sudo' 'ln')
        rm=('koopa::rm' '-S')
    else
        ln=('ln')
        rm=('koopa::rm')
    fi
    source_file="${1:?}"
    target_file="${2:?}"
    "${rm[@]}" "$target_file"
    "${ln[@]}" -fns "$source_file" "$target_file"
    return 0
}

koopa::mkdir() { # {{{1
    # """
    # Create directories with parents automatically.
    # @note Updated 2020-07-06.
    local OPTIND mkdir sudo
    koopa::assert_has_args "$#"
    OPTIND=1
    while getopts 'S' opt
    do
        case "$opt" in
            S)
                sudo=1
                ;;
            \?)
                koopa::stop "Invalid option: -${OPTARG}"
            ;;
        esac
    done
    shift "$((OPTIND-1))"
    if [[ "$sudo" -eq 1 ]]
    then
        mkdir=('sudo' 'mkdir')
    else
        mkdir=('mkdir')
    fi
    "${mkdir[@]}" -p "$@"
    return 0
}

koopa::mv() { # {{{1
    # """
    # Move a file or directory.
    # @note Updated 2020-07-06.
    #
    # This function works on 1 file or directory at a time.
    # It ensures that the target parent directory exists automatically.
    #
    # Useful GNU cp flags, for reference (non-POSIX):
    # - -T: no-target-directory
    # - --strip-trailing-slashes
    # """
    local OPTIND mkdir mv rm source_file sudo target_file
    koopa::assert_has_args_eq "$#" 2
    OPTIND=1
    while getopts 'S' opt
    do
        case "$opt" in
            S)
                sudo=1
                ;;
            \?)
                koopa::stop "Invalid option: -${OPTARG}"
            ;;
        esac
    done
    shift "$((OPTIND-1))"
    if [[ "$sudo" -eq 1 ]]
    then
        mkdir=('koopa::mkdir' '-S')
        mv=('sudo' 'mv')
        rm=('koopa::rm' '-S')
    else
        mkdir=('koopa::mkdir')
        mv=('mv')
        rm=('koopa::rm')
    fi
    source_file="$(koopa::strip_trailing_slash "${1:?}")"
    koopa::assert_is_existing "$source_file"
    target_file="$(koopa::strip_trailing_slash "${2:?}")"
    [[ -e "$target_file" ]] && "${rm[@]}" "$target_file"
    "${mkdir[@]}" "$(dirname "$target_file")"
    "${mv[@]}" -f "$source_file" "$target_file"
    return 0
}

koopa::relink() { # {{{1
    # """
    # Re-create a symbolic link dynamically, if broken.
    # @note Updated 2020-07-06.
    # """
    local OPTIND dest_file ln rm source_file sudo
    koopa::assert_has_args_eq "$#" 2
    OPTIND=1
    while getopts 'S' opt
    do
        case "$opt" in
            S)
                sudo=1
                ;;
            \?)
                koopa::stop "Invalid option: -${OPTARG}"
            ;;
        esac
    done
    shift "$((OPTIND-1))"
    if [[ "$sudo" -eq 1 ]]
    then
        ln=('sudo' 'ln')
        rm=('koopa::rm' '-S')
    else
        ln=('ln')
        rm=('koopa::rm')
    fi
    source_file="${1:?}"
    dest_file="${2:?}"
    # Keep this check relaxed, in case dotfiles haven't been cloned.
    [[ -e "$source_file" ]] || return 0
    [[ -L "$dest_file" ]] && return 0
    "${rm[@]}" "$dest_file"
    "${ln[@]}" -fns "$source_file" "$dest_file"
    return 0
}

koopa::rm() { # {{{1
    # """
    # Remove files/directories quietly.
    # @note Updated 2020-07-06.
    # """
    local OPTIND rm sudo
    koopa::assert_has_args "$#"
    OPTIND=1
    while getopts 'S' opt
    do
        case "$opt" in
            S)
                sudo=1
                ;;
            \?)
                koopa::stop "Invalid option: -${OPTARG}"
            ;;
        esac
    done
    shift "$((OPTIND-1))"
    if [[ "$sudo" -eq 1 ]]
    then
        rm=('sudo' 'rm')
    else
        rm=('rm')
    fi
    "${rm[@]}" -fr "$@" &>/dev/null
    return 0
}

