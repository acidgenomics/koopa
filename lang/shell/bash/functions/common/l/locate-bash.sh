#!/usr/bin/env bash

# FIXME Rework the variables here.
# FIXME Use '--app-name' instead of '--opt-name'
# FIXME Use '--bin-name=' instead of '--app-name'.
# Less confusing.

koopa_locate_bash() {
    koopa_locate_app \
        --app-name='bash' \
        --opt-name='bash' \
        "$@"
}
