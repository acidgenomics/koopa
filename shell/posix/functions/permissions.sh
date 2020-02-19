# FIXME Need to think of a better non-recursive name here.
# FIXME Alternatively, rename '_koopa_set_permissions'? This seems confusing.
_koopa_set_permissions_FIXME() {  # {{{1
    # """
    # Set permissions on a single file or directory only.
    echo "FIXME"
}



# FIXME Rename this.
_koopa_prefix_chgrp() {  # {{{1
    # """
    # Set group for target prefix(es).
    # @note Updated 2020-02-19.
    # """
    _koopa_chgrp \
        --no-dereference \
        --recursive \
        "$(_koopa_group)" \
        "$@"
    return 0
}

# FIXME Rename this.
_koopa_prefix_chmod() {  # {{{1
    # """
    # Set file permissions for target prefix(es).
    # @note Updated 2020-02-16.
    #
    # This sets group write access by default for shared install, which is
    # useful so we don't have to constantly switch to root for admin.
    # """
    _koopa_chmod \
        --recursive \
        "$(_koopa_chmod_flags)" \
        "$@"
    return 0
}

# FIXME Rename this.
_koopa_prefix_chown() {  # {{{1
    # """
    # Set ownership (user and group) for target prefix(es).
    # @note Updated 2020-02-19.
    # """
    _koopa_chown \
        --no-dereference \
        --recursive \
        "$(_koopa_user):$(_koopa_group)" \
        "$@"
    return 0
}

# FIXME Rename this.
_koopa_prefix_chown_user() {  # {{{1
    # """
    # Set ownership to current user for target prefix(es).
    # @note Updated 2020-02-19.
    # """
    _koopa_chown \
        --no-dereference \
        --recursive \
        "${USER:?}:$(_koopa_group)" \
        "$@"
    return 0
}

_koopa_set_permissions() {  # {{{1
    # """
    # Set permissions on target prefix(es).
    # @note Updated 2020-01-24.
    #
    # This always works recursively.
    # """
    [ "$#" -eq 1 ] || return 1
    local prefix
    prefix="${1:?}"
    _koopa_h2 "Setting permissions on '${prefix}'."
    _koopa_prefix_chown "$prefix"
    _koopa_prefix_chmod "$prefix"
    return 0
}

_koopa_set_permissions_user() {  # {{{1
    # """
    # Set permissions on target prefix(es) to current user.
    # @note Updated 2020-01-24.
    #
    # This always works recursively.
    # """
    [ "$#" -eq 1 ] || return 1
    local prefix
    prefix="${1:?}"
    _koopa_h2 "Resetting permissions on '${prefix}'."
    _koopa_prefix_chown_user "$prefix"
    _koopa_prefix_chmod "$prefix"
    return 0
}

_koopa_set_sticky_group() {  # {{{1
    # """
    # Set sticky group bit for target prefix(es).
    # @note Updated 2020-01-24.
    #
    # This never works recursively.
    # """
    _koopa_chmod g+s "$@"
    return 0
}
