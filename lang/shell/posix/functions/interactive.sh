#!/bin/sh
# koopa nolint=coreutils

_koopa_git_branch() { # {{{1
    # """
    # Current git branch name.
    # @note Updated 2020-07-05.
    #
    # This is used in prompt, so be careful with assert checks.
    #
    # Handles detached HEAD state.
    #
    # Alternatives:
    # > git name-rev --name-only HEAD
    # > git rev-parse --abbrev-ref HEAD
    #
    # @seealso
    # - https://git.kernel.org/pub/scm/git/git.git/tree/contrib/completion/
    #       git-completion.bash?id=HEAD
    # """
    local branch
    _koopa_is_git || return 0
    _koopa_is_installed git || return 0
    branch="$(git symbolic-ref --short -q HEAD 2>/dev/null)"
    _koopa_print "$branch"
    return 0
}

_koopa_tmux_sessions() { # {{{1
    # """
    # Show active tmux sessions.
    # @note Updated 2021-03-18.
    # """
    local x
    _koopa_is_installed tmux || return 0
    _koopa_is_tmux && return 0
    x="$(tmux ls 2>/dev/null || true)"
    [ -n "$x" ] || return 0
    x="$(_koopa_print "$x" | cut -d ':' -f 1 | tr '\n' ' ')"
    _koopa_dl 'tmux' "$x"
    return 0
}

_koopa_today_bucket() { # {{{1
    # """
    # Create a dated file today bucket.
    # @note Updated 2020-07-05.
    #
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
    # """
    local bucket_dir today_bucket today_link
    bucket_dir="${KOOPA_BUCKET:-}"
    [ -z "$bucket_dir" ] && bucket_dir="${HOME:?}/bucket"
    # Early return if there's no bucket directory on the system.
    [ -d "$bucket_dir" ] || return 0
    today_bucket="$(date '+%Y/%m/%d')"
    today_link="${HOME:?}/today"
    # Early return if we've already updated the symlink.
    _koopa_is_installed readlink || return 0
    _koopa_str_match "$(readlink "$today_link")" "$today_bucket" && return 0
    mkdir -p "${bucket_dir}/${today_bucket}"
    ln -fns "${bucket_dir}/${today_bucket}" "$today_link"
    return 0
}
