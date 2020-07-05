#!/usr/bin/env bash

# FIXME SAVE TO MOVE? USED IN TODAY ACTIVATE SCRIPT?
# FIXME ADD SUPPORT FOR -S SUDO FLAG
koopa::ln() { # {{{1
    # """
    # Create a symlink quietly.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_args_eq "$#" 2
    koopa::assert_is_installed ln
    local source_file target_file
    source_file="${1:?}"
    target_file="${2:?}"
    koopa::rm "$target_file"
    ln -fns "$source_file" "$target_file"
    return 0
}

# FIXME ADD SUPPORT FOR -S SUDO FLAG
koopa::mkdir() { # {{{1
    # """
    # Create directories with parents automatically.
    # @note Updated 2020-07-04.
    koopa::assert_has_args "$#"
    mkdir -pv "$@"
    return 0
}

# FIXME ADD SUPPORT FOR -S SUDO FLAG
koopa::mv() { # {{{1
    # """
    # Move a file or directory.
    # @note Updated 2020-07-04.
    #
    # This function works on 1 file or directory at a time.
    # It ensures that the target parent directory exists automatically.
    #
    # Useful GNU cp flags, for reference (non-POSIX):
    # - -T: no-target-directory
    # - --strip-trailing-slashes
    # """
    koopa::assert_has_args_eq "$#" 2
    local source_file target_file
    source_file="$(koopa::strip_trailing_slash "${1:?}")"
    koopa::assert_is_existing "$source_file"
    target_file="$(koopa::strip_trailing_slash "${2:?}")"
    [ -e "$target_file" ] && koopa::rm "$target_file"
    koopa::mkdir "$(dirname "$target_file")"
    mv -f "$source_file" "$target_file"
    return 0
}

# FIXME ADD SUDO -S FLAG SUPPORT
koopa::relink() { # {{{1
    # """
    # Re-create a symbolic link dynamically, if broken.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args_eq "$#" 2
    local dest_file source_file
    source_file="${1:?}"
    dest_file="${2:?}"
    # Keep this check relaxed, in case dotfiles haven't been cloned.
    [ -e "$source_file" ] || return 0
    [ -L "$dest_file" ] && return 0
    koopa::rm "$dest_file"
    ln -fns "$source_file" "$dest_file"
    return 0
}

# FIXME ADD SUDO -S FLAG SUPPORT
koopa::rm() { # {{{1
    # """
    # Remove files/directories quietly.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    rm -fr "$@" >/dev/null 2>&1
    return 0
}

