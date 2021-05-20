#!/usr/bin/env bash

koopa::chmod() { # {{{1
    # """
    # GNU chmod.
    # @note Updated 2021-05-20.
    # """
    local brew_prefix chmod pos sudo which_chmod
    which_chmod='chmod'
    if koopa::is_macos
    then
        brew_prefix="$(koopa::homebrew_prefix)"
        which_chmod="${brew_prefix}/bin/gchmod"
    fi
    koopa::assert_is_installed "$which_chmod"
    koopa::assert_is_gnu "$which_chmod"
    sudo=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            -S)
                sudo=1
                shift 1
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_no_args "$#"
    if [[ "$sudo" -eq 1 ]]
    then
        chmod=('sudo' "$which_chmod")
    else
        chmod=("$which_chmod")
    fi
    "${chmod[@]}" "$@"
    return 0
}

koopa::chown() { # {{{1
    # """
    # GNU chown.
    # @note Updated 2021-05-20.
    # """
    local brew_prefix chown pos sudo which_chown
    which_chown='chown'
    if koopa::is_macos
    then
        brew_prefix="$(koopa::homebrew_prefix)"
        which_chown="${brew_prefix}/bin/gchown"
    fi
    koopa::assert_is_installed "$which_chown"
    koopa::assert_is_gnu "$which_chown"
    sudo=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            -S)
                sudo=1
                shift 1
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_no_args "$#"
    if [[ "$sudo" -eq 1 ]]
    then
        chown=('sudo' "$which_chown")
    else
        chown=("$which_chown")
    fi
    "${chown[@]}" "$@"
    return 0
}

koopa::cp() { # {{{1
    # """
    # Hardened version of GNU coreutils copy.
    # @note Updated 2021-05-19.
    #
    # getopts info:
    # - http://mywiki.wooledge.org/BashFAQ/035#getopts
    # - https://wiki.bash-hackers.org/howto/getopts_tutorial
    # """
    local OPTIND brew_prefix cp cp_args mkdir rm sudo symlink \
        target_dir target_parent which_cp
    which_cp='cp'
    if koopa::is_macos
    then
        brew_prefix="$(koopa::homebrew_prefix)"
        which_cp="${brew_prefix}/bin/gcp"
    fi
    koopa::assert_is_gnu "$which_cp"
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
        cp=('sudo' "$which_cp")
        mkdir=('koopa::mkdir' '-S')
        rm=('koopa::rm' '-S')
    else
        cp=("$which_cp")
        mkdir=('koopa::mkdir')
        rm=('koopa::rm')
    fi
    cp_args=('-af')
    [[ "$symlink" -eq 1 ]] && cp_args+=('-s')
    if [[ -n "$target_dir" ]]
    then
        koopa::assert_is_existing "$@"
        target_dir="$(koopa::strip_trailing_slash "$target_dir")"
        cp_args+=('-t' "$target_dir")
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
    "${cp[@]}" "${cp_args[@]}" "$@"
    return 0
}

koopa::df() { # {{{1
    # """
    # Human friendlier version of GNU df.
    # @note Updated 2021-05-19.
    # """
    local brew_prefix df
    df='df'
    if koopa::is_macos
    then
        brew_prefix="$(koopa::homebrew_prefix)"
        df="${brew_prefix}/bin/gdf"
    fi
    koopa::assert_is_gnu "$df"
    "$df" \
        --portability \
        --print-type \
        --si \
        "$@"
    return 0
}

koopa::ln() { # {{{1
    # """
    # Create a symlink quietly with GNU ln.
    # @note Updated 2021-05-20.
    # """
    local OPTIND brew_prefix ln ln_args mkdir rm source_file target_file \
        target_dir target_parent which_ln
    which_ln='ln'
    if koopa::is_macos
    then
        brew_prefix="$(koopa::homebrew_prefix)"
        which_ln="${brew_prefix}/bin/gln"
    fi
    koopa::assert_is_gnu "$which_ln"
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
        ln=('sudo' "$which_ln")
        mkdir=('koopa::mkdir' '-S')
        rm=('koopa::rm' '-S')
    else
        ln=("$which_ln")
        mkdir=('koopa::mkdir')
        rm=('koopa::rm')
    fi
    ln_args=('-fns')
    if [[ -n "$target_dir" ]]
    then
        koopa::assert_is_existing "$@"
        target_dir="$(koopa::strip_trailing_slash "$target_dir")"
        ln_args+=('-t' "$target_dir")
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
    "${ln[@]}" "${ln_args[@]}" "$@"
    return 0
}

koopa::mkdir() { # {{{1
    # """
    # Create directories with parents automatically.
    # @note Updated 2021-05-19.
    local OPTIND brew_prefix mkdir sudo which_mkdir
    which_mkdir='mkdir'
    if koopa::is_macos
    then
        brew_prefix="$(koopa::homebrew_prefix)"
        which_mkdir="${brew_prefix}/bin/gmkdir"
    fi
    koopa::assert_is_gnu "$which_mkdir"
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
        mkdir=('sudo' "$which_mkdir")
    else
        mkdir=("$which_mkdir")
    fi
    "${mkdir[@]}" -p "$@"
    return 0
}

koopa::mv() { # {{{1
    # """
    # Move a file or directory with GNU mv.
    # @note Updated 2021-05-19.
    #
    # This function works on 1 file or directory at a time.
    # It ensures that the target parent directory exists automatically.
    #
    # Useful GNU mv args, for reference (non-POSIX):
    # - -T: no-target-directory
    # - --strip-trailing-slashes
    # """
    local OPTIND brew_prefix mkdir mv mv_args rm source_file sudo \
        target_file target_parent which_mv
    which_mv='mv'
    if koopa::is_macos
    then
        brew_prefix="$(koopa::homebrew_prefix)"
        which_mv="${brew_prefix}/bin/gmv"
    fi
    koopa::assert_is_gnu "$which_mv"
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
        mv=('sudo' "$which_mv")
        rm=('koopa::rm' '-S')
    else
        mkdir=('koopa::mkdir')
        mv=("$which_mv")
        rm=('koopa::rm')
    fi
    mv_args=('-f')
    if [[ -n "$target_dir" ]]
    then
        koopa::assert_is_existing "$@"
        target_dir="$(koopa::strip_trailing_slash "$target_dir")"
        mv_args+=('-t' "$target_dir")
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
    "${mv[@]}" "${mv_args[@]}" "$@"
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
    # Remove files/directories quietly with GNU rm.
    # @note Updated 2021-05-19.
    # """
    local OPTIND brew_prefix rm sudo which_rm
    which_rm='rm'
    if koopa::is_macos
    then
        brew_prefix="$(koopa::homebrew_prefix)"
        which_rm="${brew_prefix}/bin/grm"
    fi
    koopa::assert_is_gnu "$which_rm"
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
        rm=('sudo' "$which_rm")
    else
        rm=("$which_rm")
    fi
    "${rm[@]}" -fr "$@"
    return 0
}

koopa::sed() { # {{{1
    # """
    # GNU sed.
    # @note Updated 2021-05-20.
    # """
    koopa::assert_has_args "$#"
    sed='sed'
    if koopa::is_macos
    then
        brew_prefix="$(koopa::homebrew_prefix)"
        sed="${brew_prefix}/bin/gsed"
    fi
    koopa::assert_is_installed "$sed"
    "$sed" "$@"
    return 0
}
