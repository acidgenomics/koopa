# koopa shell
# https://github.com/acidgenomics/koopa
KOOPA_DIR="/usr/local/koopa"
if [ -z "${KOOPA_SHELL:-}" ]
then
    # shellcheck source=/dev/null
    . "${KOOPA_DIR}/activate"
fi
