#!/bin/sh

# In bash, here's how to check cleanup.
# declare -p: All variables and functions, with values.
# delcare -F: Function names only.

unset -v \
    BASE_DIR \
    EXTRA_DIR \
    KOOPA_ACTIVATED \
    KOOPA_SOURCE \
    KOOPA_SYSTEM_DIR

unset -f \
    add_to_path_end \
    add_to_path_start \
    force_add_to_path_start \
    pathmunge \
    quiet_expr \
    quiet_which \
    remove_from_path
