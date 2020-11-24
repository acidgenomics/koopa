#!/bin/sh
# koopa nolint=coreutils

# """
# POSIX shell header.
# @note Updated 2020-11-24.
# """

if [ -z "${KOOPA_PREFIX:-}" ]
then
    printf '%s\n' "ERROR: Required 'KOOPA_PREFIX' is unset." >&2
    exit 1
fi

# Source POSIX functions.
# Use shell globbing instead of 'find', which doesn't support source.
for file in "${KOOPA_PREFIX}/shell/posix/functions/"*'.sh'
do
    # shellcheck source=/dev/null
    [ -f "$file" ] && . "$file"
done
unset -v file

if [ "${KOOPA_ACTIVATE:-1}" -eq 1 ]
then
    _koopa_activate_xdg
    _koopa_activate_standard_paths
    _koopa_activate_koopa_paths
    _koopa_activate_pkg_config
    _koopa_activate_python_site_packages
fi

# This value is picked up in R configuration (for reticulate).
KOOPA_OPT_PREFIX="$(_koopa_opt_prefix)"
export KOOPA_OPT_PREFIX
