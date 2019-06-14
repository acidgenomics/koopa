# koopa shell
# https://github.com/acidgenomics/koopa
if [ -z "${KOOPA_SHELL:-}" ]
then
    # shellcheck source=/dev/null
    . /usr/local/koopa/activate
fi
