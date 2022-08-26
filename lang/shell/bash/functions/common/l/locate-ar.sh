#!/usr/bin/env bash

# FIXME Should we use system AR instead?
# FIXME Do we need to update this to prefix with g?

koopa_locate_ar() {
    koopa_locate_app \
        --app-name='ar' \
        --opt-name='binutils' \
        "$@"
}
